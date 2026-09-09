import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/helper/utils/keyboardOverlay.dart';
import 'package:project/models/orderDetail.dart';
import 'package:project/provider/pickupOrdersStatusUpdateProvider.dart';
import 'package:project/provider/returnOrdersStatusUpdateProvider.dart';
import 'package:project/models/returnOrderDetail.dart';
import 'package:project/provider/returnOrderDetailProvider.dart';
import 'package:project/screens/orderDetailScreen/widget/actionButtonWidget.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  final String? from;
  final String? returnOrderId;
  final bool? isReturn;

  const OrderDetailScreen({Key? key, required this.orderId, this.from, this.isReturn, this.returnOrderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  List lblOrderStatusDisplayNames = [];
  String _selectedReturnDeliveryBoyId = "";
  String _selectedReturnDeliveryBoyName = "";

  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      bool hasFocus = focusNode.hasFocus;
      if (hasFocus) {
        KeyboardOverlay.showOverlay(context);
      } else {
        KeyboardOverlay.removeOverlay();
      }
    });
    //fetch categoryList from api
    Future.delayed(Duration.zero).then((value) {
      lblOrderStatusDisplayNames = widget.from == "return"
          ? [
              getTranslatedValue(context, orderReturnStatusDisplayNamesPendingLabel),
              getTranslatedValue(context, orderReturnStatusDisplayNamesApprovedLabel),
              getTranslatedValue(context, orderReturnStatusDisplayNamesRejectedLabel),
              getTranslatedValue(context, orderReturnStatusDisplayNamesDeliveryBoyAssignedLabel),
            ]
          : widget.from == "selfpickup"
              ? [
                  getTranslatedValue(context, orderStatusDisplayNamesAwaitingLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesPendingLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesReadyForPickupLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesPickedUpLabel)
                ]
              : [
                  getTranslatedValue(context, orderStatusDisplayNamesAwaitingLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesReceivedLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesProcessedLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesShippedLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesOutForDeliveryLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesDeliveredLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesCancelledLabel),
                  getTranslatedValue(context, orderStatusDisplayNamesReturnedLabel),
                ];

      if (widget.from == "return") {
        context.read<ReturnOrderDetailProvider>().getReturnOrderDetail(
          context: context,
          returnRequestId: widget.returnOrderId ?? widget.orderId,
        );
      } else {
        context.read<OrderDetailProvider>().getOrderDetail(context: context, orderId: widget.orderId);
      }
    });
  }

  @override
  dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isPickup = widget.from == "selfpickup";
    final bool isReturn = widget.from == "return";
    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          text: "${getTranslatedValue(context, titleOrderLabel)} #${widget.orderId}",
          style: TextStyle(color: ColorsRes.mainTextColor),
        ),
      ),
      body: isReturn
          ? Consumer<ReturnOrderDetailProvider>(
              builder: (context, returnProvider, child) {
                if (returnProvider.state == ReturnOrderDetailState.loaded) {
                  ReturnOrderDetailData? data = returnProvider.returnOrderDetail?.data;
                  ReturnItem? returnItem = data?.returnItem;
                  return setRefreshIndicator(
                    refreshCallback: () => returnProvider.getReturnOrderDetail(
                      context: context,
                      returnRequestId: widget.returnOrderId ?? widget.orderId,
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ListView(
                              children: [
                                // Billing Details
                                CustomTextLabel(
                                  jsonKey: billingDetailsLabel,
                                  style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                                ),
                                getSizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.all(Constant.paddingOrMargin10),
                                  margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                                  decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      getOrderDetailContainer(
                                        titleFlex: 5, valueFlex: 10,
                                        title: getTranslatedValue(context, orderDateLabel),
                                        value: (data?.createdAt == null || data?.createdAt == "null")
                                            ? DateTime.now().toString().formatDate()
                                            : /* DateTime.parse( */data!.createdAt??""/* ) */.toString()/* .formatDate() */,
                                      ),
                                      getSizedBox(height: 10),
                                      getOrderDetailContainer(
                                        titleFlex: 5, valueFlex: 10,
                                        title: getTranslatedValue(context, userMobileLabel),
                                        value: data?.customerMobile ?? "",
                                      ),
                                      getSizedBox(height: 10),
                                      getOrderDetailContainer(
                                        titleFlex: 5, valueFlex: 10,
                                        title: getTranslatedValue(context, cityLabel),
                                        value: data?.cityName ?? "",
                                      ),
                                      getSizedBox(height: 10),
                                      getOrderDetailContainer(
                                        titleFlex: 5, valueFlex: 10,
                                        title: getTranslatedValue(context, refundAmountLabel),
                                        value: getCurrencyFormat(double.parse((data?.returnItem?.amountToRefund ?? 0.0).toString())),
                                      ),
                                    ],
                                  ),
                                ),
                                // List of Return Items
                                CustomTextLabel(
                                  jsonKey: returnItemLabel,
                                  style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                                ),
                                getSizedBox(height: 10),
                                Container(
                                  padding: EdgeInsets.all(Constant.paddingOrMargin10),
                                  margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                                  decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: CustomTextLabel(
                                              text: "${data?.productName ?? ""} (${data?.variantName ?? ""})",
                                              softWrap: true,
                                              style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 15),
                                            ),
                                          ),
                                        ],
                                      ),
                                      getSizedBox(height: 10),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.all(Radius.circular(10)),
                                              child: setNetworkImg(
                                                image: returnItem?.image ?? "",
                                                width: context.width * 0.22,
                                                height: context.width * 0.22,
                                                boxFit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          getSizedBox(width: 10),
                                          Expanded(
                                            flex: 2,
                                            child: Column(
                                              children: [
                                                getOrderDetailContainer(
                                                  title: getTranslatedValue(context, quantityLabel),
                                                  value: data?.quantity ?? "1",
                                                ),
                                                getSizedBox(height: 5),
                                                getOrderDetailContainer(
                                                  title: getTranslatedValue(context, priceLabel),
                                                  value: getCurrencyFormat(
                                                    double.parse(double.parse(data?.discountedPrice ?? "0.0") > 0
                                                        ? (data?.discountedPrice ?? "0.0")
                                                        : (data?.price ?? "0.0")),
                                                  ),
                                                ),
                                                getSizedBox(height: 5),
                                                getOrderDetailContainer(
                                                  title: getTranslatedValue(context, subtotalLabel),
                                                  value: getCurrencyFormat(double.parse(data?.subTotal ?? "0.0")),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Reason / Remark
                                if ((data?.reason ?? "").isNotEmpty || (data?.remarks ?? "").isNotEmpty) ...[
                                  CustomTextLabel(
                                    jsonKey: returnDetailLabel,
                                    style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                                  ),
                                  getSizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.all(Constant.paddingOrMargin10),
                                    margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                                    decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if ((data?.reason ?? "").isNotEmpty)
                                          getOrderDetailContainer(
                                            titleFlex: 5, valueFlex: 10,
                                            title: getTranslatedValue(context, reasonLabel),
                                            value: data?.reason ?? "",
                                          ),
                                        if ((data?.reason ?? "").isNotEmpty && (data?.remarks ?? "").isNotEmpty)
                                          getSizedBox(height: 10),
                                        if ((data?.remarks ?? "").isNotEmpty)
                                          getOrderDetailContainer(
                                            titleFlex: 5, valueFlex: 10,
                                            title: getTranslatedValue(context, remarkLabel),
                                            value: data?.remarks ?? "",
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          // Action Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              if (Constant.session.isSeller())
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      if (data?.deliveryBoyId == null ||
                                          data!.deliveryBoyId!.isEmpty ||
                                          data.deliveryBoyId == "0" /* order.deliveryBoyId?.trim().isEmpty ?? false */ ) {
                                        showModalBottomSheet<String?>(
                                          backgroundColor: Theme.of(context).cardColor,
                                          context: context,
                                          isScrollControlled: true,
                                          shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                                          builder: (BuildContext context) {
                                            return MultiProvider(
                                              providers: [
                                                ChangeNotifierProvider(create: (context) => DeliveryBoysProvider()),
                                                ChangeNotifierProvider(create: (context) => OrderUpdateStatusProvider()),
                                                ChangeNotifierProvider(create: (context) => OrderDetailProvider()),
                                                ChangeNotifierProvider(create: (context) => ReturnOrderUpdateStatusProvider()),
                                              ],
                                              child: Consumer<DeliveryBoysProvider>(
                                                builder: (context, deliveryBoysProvider, child) {
                                                  if (context.read<DeliveryBoysProvider>().deliveryBoysState == ProductDeliveryBoysState.initial) {
                                                    if (deliveryBoysProvider.deliveryBoysList.isEmpty) {
                                                      deliveryBoysProvider.getDeliveryBoys(
                                                        selectedDeliveryBoyIndex: int.parse(
                                                          "${data!.deliveryBoyId.toString().isEmpty ? "0" : data.deliveryBoyId.toString()}",
                                                        ),
                                                        context: context,
                                                        orderId: data.orderId!,
                                                      );
                                                    }
                                                  }
                                                  return Container(
                                                    padding: EdgeInsetsDirectional.only(
                                                      start: Constant.paddingOrMargin15,
                                                      end: Constant.paddingOrMargin15,
                                                      top: Constant.paddingOrMargin15,
                                                      bottom: Constant.paddingOrMargin15,
                                                    ),
                                                    child: Column(
                                                      mainAxisSize: .min,
                                                      children: [
                                                        Center(
                                                          child: CustomTextLabel(
                                                            jsonKey: updateDeliveryBoyLabel,
                                                            softWrap: true,
                                                            textAlign: TextAlign.center,
                                                            style: Theme.of(context).textTheme.titleMedium!.merge(
                                                              TextStyle(letterSpacing: 0.5, color: ColorsRes.mainTextColor),
                                                            ),
                                                          ),
                                                        ),
                                                        getSizedBox(height: 10),
                                                        if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded ||
                                                            deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loadingMore ||
                                                            deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating)
                                                          Column(
                                                            children: List.generate(deliveryBoysProvider.deliveryBoysList.length, (index) {
                                                              return GestureDetector(
                                                                onTap: () {
                                                                  deliveryBoysProvider.setSelectedIndex(
                                                                    deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                                  );
                                                                },
                                                                child: Container(
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: Padding(
                                                                          padding: EdgeInsetsDirectional.only(start: Constant.paddingOrMargin10),
                                                                          child: CustomTextLabel(
                                                                            text:
                                                                                "${deliveryBoysProvider.deliveryBoysList[index].translations?.name ?? ""}(${getTranslatedValue(context, pendingOrdersLabel)} - ${deliveryBoysProvider.deliveryBoysList[index].pendingOrderCount ?? "0"})",
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Radio(
                                                                        activeColor: ColorsRes.appColor,
                                                                        value: context.read<DeliveryBoysProvider>().selectedDeliveryBoy,
                                                                        groupValue: deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                                        onChanged: (value) {
                                                                          deliveryBoysProvider.setSelectedIndex(
                                                                            deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                                          );
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            }),
                                                          ),
                                                        if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loading)
                                                          Column(
                                                            children: List.generate(8, (index) {
                                                              return CustomShimmer(
                                                                height: 30,
                                                                width: double.maxFinite,
                                                                margin: EdgeInsetsDirectional.all(10),
                                                              );
                                                            }),
                                                          ),
                                                        getSizedBox(height: 10),
                                                        if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating ||
                                                            deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded)
                                                          Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: Constant.paddingOrMargin10),
                                                            child: gradientBtnWidget(
                                                              context,
                                                              10,
                                                              callback: () {
                                                                final selectedId = deliveryBoysProvider.selectedDeliveryBoy.toString();
                                                                final selectedBoy = deliveryBoysProvider.deliveryBoysList.firstWhere(
                                                                  (b) => b.id.toString() == selectedId,
                                                                  orElse: () => deliveryBoysProvider.deliveryBoysList.first,
                                                                );
                                                                _selectedReturnDeliveryBoyName = selectedBoy.translations?.name ?? '';
                                                                Navigator.pop(context, selectedId);
                                                              },
                                                              otherWidgets: Container(
                                                                child: (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating)
                                                                    ? CircularProgressIndicator(color: ColorsRes.appColorWhite)
                                                                    : (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded)
                                                                    ? CustomTextLabel(
                                                                        jsonKey: updateDeliveryBoyLabel,
                                                                        softWrap: true,
                                                                        style: Theme.of(context).textTheme.titleMedium!.merge(
                                                                          TextStyle(
                                                                            color: ColorsRes.appColorWhite,
                                                                            letterSpacing: 0.5,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                              ),
                                                            ),
                                                          ),
                                                        if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loading)
                                                          Padding(
                                                            padding: EdgeInsetsDirectional.only(
                                                              start: Constant.paddingOrMargin10,
                                                              end: Constant.paddingOrMargin10,
                                                            ),
                                                            child: CustomShimmer(height: 55, width: double.maxFinite),
                                                          ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        ).then((value) {
                                          if (value is String && value.isNotEmpty) {
                                            setState(() {
                                              _selectedReturnDeliveryBoyId = value;
                                            });
                                          }
                                          returnProvider.getReturnOrderDetail(context: context, returnRequestId: widget.returnOrderId ?? widget.orderId);
                                        });
                                      }
                                    },
                                    child: Container(
                                      alignment: AlignmentDirectional.centerStart,
                                      margin: EdgeInsetsDirectional.only(end: 5),
                                      padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: ColorsRes.appColor, width: 1),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      CustomTextLabel(
                                                        jsonKey: deliveryBoyLabel,
                                                        style: TextStyle(fontSize: 14, color: ColorsRes.grey),
                                                        softWrap: true,
                                                      ),
                                                      getSizedBox(height: 2),
                                                      CustomTextLabel(
                                                        text: _selectedReturnDeliveryBoyName.isNotEmpty
                                                            ? _selectedReturnDeliveryBoyName
                                                            : (data?.deliveryBoyName == null ||
                                                                    data?.deliveryBoyName == "null" ||
                                                                    (data?.deliveryBoyName ?? "").isEmpty)
                                                                ? getTranslatedValue(context, notAssignLabel)
                                                                : data?.deliveryBoyName ?? "",
                                                        style: TextStyle(fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        softWrap: true,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Icon(Icons.arrow_drop_down),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet<void>(
                                      backgroundColor: Theme.of(context).cardColor,
                                      context: context,
                                      isScrollControlled: true,
                                      shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                                      builder: (BuildContext context) {
                                        return ChangeNotifierProvider(
                                          create: (_) => ReturnOrderUpdateStatusProvider(),
                                          child: Consumer<ReturnOrderUpdateStatusProvider>(
                                            builder: (context, returnOrdersProvider, child) {
                                              if (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.initial) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  returnOrdersProvider.setSelectedStatus(
                                                    (int.parse(data?.status.toString() ?? "1") - 1).toString(),
                                                  );
                                                  returnOrdersProvider.getOrdersStatuses(context: context, from: "return", returnRequestId: widget.returnOrderId);
                                                });
                                              }
                                              return Container(
                                                padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Center(
                                                      child: CustomTextLabel(
                                                        jsonKey: updateOrderStatusLabel,
                                                        softWrap: true,
                                                        textAlign: TextAlign.center,
                                                        style: Theme.of(context).textTheme.titleMedium!.merge(
                                                          TextStyle(letterSpacing: 0.5, color: ColorsRes.mainTextColor),
                                                        ),
                                                      ),
                                                    ),
                                                    getSizedBox(height: 10),
                                                    if (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.loaded ||
                                                        returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.updating)
                                                      Column(
                                                        children: List.generate(
                                                          returnOrdersProvider.orderStatusesList.length,
                                                          (index) {
                                                            final isDisabled = returnOrdersProvider.orderStatusesList[index].isDisabled == "1";
                                                            return GestureDetector(
                                                              onTap: isDisabled ? null : () => returnOrdersProvider.setSelectedStatus(index.toString()),
                                                              child: Opacity(
                                                                opacity: isDisabled ? 0.4 : 1.0,
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Padding(
                                                                        padding: EdgeInsetsDirectional.only(start: Constant.paddingOrMargin10),
                                                                        child: CustomTextLabel(
                                                                          text: returnOrdersProvider.orderStatusesList[index].statusName!,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Radio(
                                                                      activeColor: ColorsRes.appColor,
                                                                      value: returnOrdersProvider.selectedOrderStatus,
                                                                      groupValue: returnOrdersProvider.orderStatusesList[index].id,
                                                                      onChanged: isDisabled ? null : (value) => returnOrdersProvider.setSelectedStatus(index.toString()),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    getSizedBox(height: 10),
                                                    if (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.loading)
                                                      Column(
                                                        children: List.generate(
                                                          4,
                                                          (index) => CustomShimmer(height: 26, width: double.maxFinite, margin: EdgeInsetsDirectional.all(10)),
                                                        ),
                                                      ),
                                                    Builder(builder: (context) {
                                                      final isSameStatus = returnOrdersProvider.selectedOrderStatus.toString() == data?.status.toString();
                                                      return AbsorbPointer(
                                                        absorbing: isSameStatus,
                                                        child: Opacity(
                                                          opacity: isSameStatus ? 0.4 : 1.0,
                                                          child: Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: Constant.paddingOrMargin10),
                                                      child: gradientBtnWidget(
                                                        context,
                                                        10,
                                                        callback: () {
                                                          Map<String, String> params = {};
                                                          params[ApiAndParams.orderId] = widget.orderId;
                                                          params[ApiAndParams.status] = returnOrdersProvider.selectedOrderStatus.toString();
                                                          params[ApiAndParams.id] = widget.returnOrderId ?? widget.orderId;
                                                          if (returnOrdersProvider.selectedOrderStatus.toString() == "4") {
                                                            params[ApiAndParams.deliveryBoyId] = _selectedReturnDeliveryBoyId.isNotEmpty
                                                                ? _selectedReturnDeliveryBoyId
                                                                : data?.deliveryBoyId ?? "";
                                                          }
                                                          if (returnOrdersProvider.selectedOrderStatus.toString() == "7") {
                                                            TextEditingController cancelReasonController = TextEditingController();
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext dialogContext) {
                                                                return AlertDialog(
                                                                  backgroundColor: Theme.of(dialogContext).cardColor,
                                                                  title: CustomTextLabel(
                                                                    jsonKey: cancellationReasonLabel,
                                                                    style: Theme.of(dialogContext).textTheme.titleMedium!.merge(
                                                                      TextStyle(color: ColorsRes.mainTextColor),
                                                                    ),
                                                                  ),
                                                                  content: editBoxWidget(
                                                                    context: dialogContext,
                                                                    edtController: cancelReasonController,
                                                                    validationFunction: (_) => optionalFieldValidation("", ""),
                                                                    label: getTranslatedValue(dialogContext, cancellationReasonLabel),
                                                                    hint: getTranslatedValue(dialogContext, enterCancellationReasonLabel),
                                                                    inputType: TextInputType.multiline,
                                                                    maxlines: 3,
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                                                      child: CustomTextLabel(text: getTranslatedValue(dialogContext, cancelLabel), style: TextStyle(color: ColorsRes.appColorRed),),
                                                                    ),
                                                                    ValueListenableBuilder(
                                                                      valueListenable: cancelReasonController,
                                                                      builder: (_, __, ___) => ElevatedButton(
                                                                        onPressed: cancelReasonController.text.trim().isNotEmpty
                                                                            ? () {
                                                                                Navigator.of(dialogContext).pop();
                                                                                params[ApiAndParams.cancellationReason] = cancelReasonController.text.trim();
                                                                                returnOrdersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                                                  Navigator.pop(context, value);
                                                                                });
                                                                              }
                                                                            : null,
                                                                        child: CustomTextLabel(text: getTranslatedValue(dialogContext, submitLabel), style: TextStyle(color: ColorsRes.appColor)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          } else {
                                                            returnOrdersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                              Navigator.pop(context, value);
                                                            });
                                                          }
                                                        },
                                                        otherWidgets: Container(
                                                          child: (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.loaded)
                                                              ? CustomTextLabel(
                                                                  jsonKey: updateOrderStatusLabel,
                                                                  softWrap: true,
                                                                  style: Theme.of(context).textTheme.titleMedium!.merge(
                                                                    TextStyle(color: ColorsRes.appColorWhite, letterSpacing: 0.5),
                                                                  ),
                                                                )
                                                              : CircularProgressIndicator(color: ColorsRes.appColorWhite),
                                                        ),
                                                      ),
                                                    ),
                                                        ),
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ).then((_) {
                                      returnProvider.getReturnOrderDetail(
                                        context: context,
                                        returnRequestId: widget.returnOrderId ?? widget.orderId,
                                      );
                                    });
                                  },
                                  child: Container(
                                    alignment: AlignmentDirectional.centerStart,
                                    padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                                    margin: EdgeInsetsDirectional.only(start: 5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: ColorsRes.appColor, width: 1),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomTextLabel(
                                                jsonKey: statusLabel,
                                                style: TextStyle(color: ColorsRes.grey),
                                                softWrap: true,
                                              ),
                                              getSizedBox(height: 2),
                                              CustomTextLabel(
                                                text: data?.orderStatusName ?? "",
                                                style: TextStyle(fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (returnProvider.state == ReturnOrderDetailState.loading) {
                  return ListView(
                    padding: EdgeInsetsDirectional.all(10),
                    children: [
                      CustomTextLabel(
                        jsonKey: billingDetailsLabel,
                        style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      getSizedBox(height: 10),
                      CustomShimmer(height: 90, width: double.maxFinite, borderRadius: 10),
                      getSizedBox(height: 10),
                      CustomTextLabel(
                        jsonKey: listOfOrderItemsLabel,
                        style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                      ),
                      getSizedBox(height: 10),
                      CustomShimmer(height: 220, width: double.maxFinite, borderRadius: 10),
                      getSizedBox(height: 10),
                      CustomShimmer(height: 160, width: double.maxFinite, borderRadius: 10),
                    ],
                  );
                } else {
                  return SizedBox.shrink();
                }
              },
            )
          : Consumer<OrderDetailProvider>(
        builder: (context, orderDetailProvider, child) {
          if (orderDetailProvider.orderDetailState == OrderDetailState.loaded ||
              orderDetailProvider.orderDetailState == OrderDetailState.silentLoading) {
            Order? order = orderDetailProvider.orderDetail.data?.order;
            List<OrderItems>? orderItems = orderDetailProvider.orderDetail.data?.orderItems;

            String customerAddress = "";
            if ((order?.customerAddress ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}" + (order?.customerAddress ?? "");
            }
            if ((order?.customerLandmark ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerLandmark ?? "");
            }
            if ((order?.customerArea ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerArea ?? "");
            }

            if ((order?.customerCity ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerCity ?? "");
            }
            if ((order?.customerState ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerState ?? "");
            }
            if ((order?.customerPincode ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerPincode ?? "");
            }
            if ((order?.customerCountry ?? "").isNotEmpty) {
              customerAddress = "${customerAddress}, " + (order?.customerCountry ?? "");
            }
            String customerAddressData = [
              order?.customerAddress,
              order?.customerLandmark,
              order?.customerArea,
              order?.customerCity,
              order?.customerState,
              order?.customerPincode,
              order?.customerCountry,
            ].where((e) => e != null && e.isNotEmpty && e != "null").join(", ");
            return setRefreshIndicator(
              refreshCallback: () {
                return orderDetailProvider.getOrderDetail(context: context, orderId: widget.orderId);
              },
              child: Padding(
                padding: EdgeInsetsDirectional.all(10),
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: .start,
                  children: [
                    Expanded(
                      child: ListView(
                        children: [
                          if (order!.orderNote.toString().isNotEmpty && order.orderNote!.toLowerCase() != "undefined") getSizedBox(height: 10),
                          if (order.orderNote.toString().isNotEmpty && order.orderNote!.toLowerCase() != "undefined")
                            Container(
                              padding: EdgeInsetsDirectional.all(10),
                              decoration: BoxDecoration(
                                color: ColorsRes.appColorYellow.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ColorsRes.appColorYellow.withValues(alpha: 0.5), width: 2),
                              ),
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  CustomTextLabel(
                                    jsonKey: orderNoteLabel,
                                    softWrap: true,
                                    style: TextStyle(color: ColorsRes.mainTextColor, fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 10),
                                  CustomTextLabel(
                                    text: order.orderNote,
                                    softWrap: true,
                                    style: TextStyle(color: ColorsRes.mainTextColor),
                                  ),
                                ],
                              ),
                            ),
                          if (order.orderNote.toString().isNotEmpty && order.orderNote!.toLowerCase() != "undefined") getSizedBox(height: 10),
                          if (Constant.viewCustomerDetail == "1")
                            CustomTextLabel(
                              jsonKey: orderDetailsLabel,
                              style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                            ),
                          if (Constant.viewCustomerDetail == "1") getSizedBox(height: 10),
                          if (Constant.viewCustomerDetail == "1")
                            Container(
                              padding: EdgeInsets.all(Constant.paddingOrMargin10),
                              margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                              decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                              child: Column(
                                crossAxisAlignment: .start,
                                children: [
                                  if (Constant.viewCustomerDetail == "1")
                                    getOrderDetailContainer(
                                        titleFlex: 5, valueFlex: 10, title: getTranslatedValue(context, userMobileLabel), value: order.mobile ?? ""),
                                  if (order.orderNote!.isNotEmpty && order.orderNote!.toLowerCase() != "undefined") getSizedBox(height: 10),
                                ],
                              ),
                            ),
                          CustomTextLabel(
                            jsonKey: billingDetailsLabel,
                            style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                          getSizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(Constant.paddingOrMargin10),
                            margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                            decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                getOrderDetailContainer(
                                  titleFlex: 5,
                                  valueFlex: 10,
                                  title: getTranslatedValue(context, orderDateLabel),
                                  value: (order.createdAt == null || order.createdAt == "null")
                                      ? DateTime.now().toString().formatDate()
                                      : /* DateTime.parse( */order.createdAt??""/* ) */.toString()/* .formatDate() */,
                                ),
                                getSizedBox(height: 10),
                                getOrderDetailContainer(
                                    titleFlex: 5,
                                    valueFlex: 10,
                                    title: getTranslatedValue(context, deliveryTimeLabel),
                                    value: order.deliveryTime ?? ""),
                                getSizedBox(height: 10),
                                getOrderDetailContainer(
                                    titleFlex: 5, valueFlex: 10, title: getTranslatedValue(context, addressLabel), value: customerAddressData),
                                Constant.session.isSeller() ? getSizedBox(height: 10) : const SizedBox.shrink(),
                                Constant.session.isSeller()
                                    ? order.additionalCharges!.isNotEmpty && widget.from != isReturn
                                        ? Column(
                                            mainAxisSize: .min,
                                            children: List.generate(
                                              order.additionalCharges!.length,
                                              (index) => Padding(
                                                  padding: EdgeInsetsDirectional.only(bottom: 10),
                                                  child: getOrderDetailContainer(
                                                    titleFlex: 5,
                                                    valueFlex: 10,
                                                    title: order.additionalCharges![index].title!,
                                                    value: getCurrencyFormat(double.parse(order.additionalCharges![index].amount ?? "0.0")),
                                                  )),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                    : const SizedBox.shrink(),
                                Constant.session.isSeller()&& widget.from != isReturn
                                    ? getOrderDetailContainer(
                                        titleFlex: 5,
                                        valueFlex: 10,
                                        title: getTranslatedValue(context, deliveryChargeLabel),
                                        value: getCurrencyFormat(double.parse(order.deliveryCharge ?? "0.0")),
                                      )
                                    : const SizedBox.shrink(),
                                Constant.session.isSeller() && widget.from != isReturn ? getSizedBox(height: 10) : const SizedBox.shrink(),
                                Constant.session.isSeller() && widget.from != isReturn
                                    ? getOrderDetailContainer(
                                        titleFlex: 5,
                                        valueFlex: 10,
                                        title: getTranslatedValue(context, totalItemsAmountLabel),
                                        value: getCurrencyFormat(double.parse(order.total ?? "0.0")),
                                      )
                                    : const SizedBox.shrink(),
                                getSizedBox(height: 10),
                                 widget.from != isReturn? getOrderDetailContainer(
                                  titleFlex: 5,
                                  valueFlex: 10,
                                  title: getTranslatedValue(context, payableAmountLabel),
                                  value: getCurrencyFormat(double.parse(order.finalTotal ?? "0.0")),
                                ): const SizedBox.shrink(),
                                 widget.from != isReturn ? getSizedBox(height: 10): const SizedBox.shrink(),
                                getOrderDetailContainer(
                                    titleFlex: 5,
                                    valueFlex: 10,
                                    title: getTranslatedValue(context, paymentMethodLabel),
                                    value: order.paymentMethod == "Wallet"
                                      ? "${getTranslatedValue(context, paidUsingWalletLabel)} (₹${order.walletBalance ?? 0})"
                                      : getTranslatedValue(context, order.paymentMethod!.toLowerCase()),
                                ),
                              ],
                            ),
                          ),
                          CustomTextLabel(
                            jsonKey: listOfOrderItemsLabel,
                            style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                          ),
                          getSizedBox(height: 10),
                          Column(
                            children: List.generate(orderItems?.length ?? 0, (index) {
                              // If isReturn is true, show only returned items (isProductReturned == "1")
                              // If isReturn is false, show all items
                              if (widget.isReturn == true) {
                                // Return mode: only show returned items
                                return orderItems![index].isProductReturned == "1"
                                    ? getOrderItemDetailsContainer(context: context, orderItem: orderItems[index], onCancelSuccess: () { context.read<OrderDetailProvider>().getOrderDetail(context: context, orderId: widget.orderId); },)
                                    : const SizedBox.shrink();
                              } else {
                                // Normal mode: show all items
                                return getOrderItemDetailsContainer(context: context, orderItem: orderItems![index], onCancelSuccess: () { context.read<OrderDetailProvider>().getOrderDetail(context: context, orderId: widget.orderId); });
                              }
                            }),
                          ),
                          if (order.deliveryProofImages != null && order.deliveryProofImages!.isNotEmpty) ...[
                            getSizedBox(height: 15),
                            CustomTextLabel(
                              jsonKey: proofOfDeliveryLabel,
                              style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                            ),
                            getSizedBox(height: 10),
                            Container(
                              width: double.maxFinite,
                              padding: EdgeInsets.all(Constant.paddingOrMargin10),
                              margin: EdgeInsetsDirectional.only(bottom: Constant.paddingOrMargin10),
                              decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextLabel(
                                    jsonKey: deliveredItemsProofLabel,
                                    style: TextStyle(color: ColorsRes.grey, fontSize: 13),
                                  ),
                                  getSizedBox(height: 10),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: List.generate(order.deliveryProofImages!.length, (index) {
                                      String imgUrl = order.deliveryProofImages![index];
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ProductFullScreenImagesScreen(
                                                images: order.deliveryProofImages!,
                                                initialPage: index,
                                              ),
                                            ),
                                          );
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(color: ColorsRes.appColor.withOpacity(0.3), width: 1),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                setNetworkImg(
                                                  image: imgUrl,
                                                  width: 85,
                                                  height: 85,
                                                  boxFit: BoxFit.cover,
                                                ),
                                                Positioned(
                                                  right: 4,
                                                  bottom: 4,
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: const BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: const Icon(
                                                      Icons.zoom_in,
                                                      size: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      crossAxisAlignment: .center,
                      children: [
                        if (Constant.session.isSeller() && !isPickup)
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (order.deliveryBoyId == null || order.deliveryBoyId!.isEmpty || order.deliveryBoyId == "0"/* order.deliveryBoyId?.trim().isEmpty ?? false */) {
                                  showModalBottomSheet<void>(
                                    backgroundColor: Theme.of(context).cardColor,
                                    context: context,
                                    isScrollControlled: true,
                                    shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                                    builder: (BuildContext context) {
                                      return MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(create: (context) => DeliveryBoysProvider()),
                                          ChangeNotifierProvider(create: (context) => OrderUpdateStatusProvider()),
                                          ChangeNotifierProvider(create: (context) => OrderDetailProvider()),
                                          ChangeNotifierProvider(create: (context) => ReturnOrderUpdateStatusProvider()),
                                        ],
                                        child: Consumer<DeliveryBoysProvider>(
                                          builder: (context, deliveryBoysProvider, child) {
                                            if (context.read<DeliveryBoysProvider>().deliveryBoysState == ProductDeliveryBoysState.initial) {
                                              if (deliveryBoysProvider.deliveryBoysList.isEmpty) {
                                                deliveryBoysProvider.getDeliveryBoys(
                                                  selectedDeliveryBoyIndex: int.parse(
                                                    "${order.deliveryBoyId.toString().isEmpty ? "0" : order.deliveryBoyId.toString()}",
                                                  ),
                                                  context: context,
                                                  orderId: order.orderId!,
                                                );
                                              }
                                            }
                                            return Container(
                                              padding: EdgeInsetsDirectional.only(
                                                start: Constant.paddingOrMargin15,
                                                end: Constant.paddingOrMargin15,
                                                top: Constant.paddingOrMargin15,
                                                bottom: Constant.paddingOrMargin15,
                                              ),
                                              child: Column(
                                                mainAxisSize: .min,
                                                children: [
                                                  Center(
                                                    child: CustomTextLabel(
                                                      jsonKey: updateDeliveryBoyLabel,
                                                      softWrap: true,
                                                      textAlign: TextAlign.center,
                                                      style: Theme.of(
                                                        context,
                                                      ).textTheme.titleMedium!.merge(TextStyle(letterSpacing: 0.5, color: ColorsRes.mainTextColor)),
                                                    ),
                                                  ),
                                                  getSizedBox(height: 10),
                                                  if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded ||
                                                      deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loadingMore ||
                                                      deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating)
                                                    Column(
                                                      children: List.generate(deliveryBoysProvider.deliveryBoysList.length, (index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            deliveryBoysProvider.setSelectedIndex(
                                                              deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                            );
                                                          },
                                                          child: Container(
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Padding(
                                                                    padding: EdgeInsetsDirectional.only(start: Constant.paddingOrMargin10),
                                                                    child: CustomTextLabel(
                                                                      text:
                                                                          "${deliveryBoysProvider.deliveryBoysList[index].translations?.name ?? ""}(${getTranslatedValue(context, pendingOrdersLabel)} - ${deliveryBoysProvider.deliveryBoysList[index].pendingOrderCount ?? "0"})",
                                                                    ),
                                                                  ),
                                                                ),
                                                                Radio(
                                                                  activeColor: ColorsRes.appColor,
                                                                  value: context.read<DeliveryBoysProvider>().selectedDeliveryBoy,
                                                                  groupValue: deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                                  onChanged: (value) {
                                                                    deliveryBoysProvider.setSelectedIndex(
                                                                      deliveryBoysProvider.deliveryBoysList[index].id.toString(),
                                                                    );
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        );
                                                      }),
                                                    ),
                                                  if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loading)
                                                    Column(
                                                      children: List.generate(8, (index) {
                                                        return CustomShimmer(
                                                          height: 30,
                                                          width: double.maxFinite,
                                                          margin: EdgeInsetsDirectional.all(10),
                                                        );
                                                      }),
                                                    ),
                                                  getSizedBox(height: 10),
                                                  if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating ||
                                                      deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded)
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: Constant.paddingOrMargin10),
                                                      child: gradientBtnWidget(
                                                        context,
                                                        10,
                                                        callback: () {
                                                          Map<String, String> params = {};
                                                          params[ApiAndParams.orderId] = order.orderId.toString();
                                                          params[ApiAndParams.deliveryBoyId] = deliveryBoysProvider.selectedDeliveryBoy.toString();

                                                          deliveryBoysProvider
                                                              .updateOrdersDeliveryBoy(params: params, context: context)
                                                              .then((value) {
                                                            Navigator.pop(context, value);
                                                          });
                                                        },
                                                        otherWidgets: Container(
                                                          child: (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.updating)
                                                              ? CircularProgressIndicator(color: ColorsRes.appColorWhite)
                                                              : (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loaded)
                                                                  ? CustomTextLabel(
                                                                      jsonKey: updateDeliveryBoyLabel,
                                                                      softWrap: true,
                                                                      style: Theme.of(context).textTheme.titleMedium!.merge(
                                                                            TextStyle(
                                                                                color: ColorsRes.appColorWhite,
                                                                                letterSpacing: 0.5,
                                                                                fontWeight: FontWeight.w500),
                                                                          ),
                                                                    )
                                                                  : Container(),
                                                        ),
                                                      ),
                                                    ),
                                                  if (deliveryBoysProvider.deliveryBoysState == ProductDeliveryBoysState.loading)
                                                    Padding(
                                                      padding: EdgeInsetsDirectional.only(
                                                        start: Constant.paddingOrMargin10,
                                                        end: Constant.paddingOrMargin10,
                                                      ),
                                                      child: CustomShimmer(height: 55, width: double.maxFinite),
                                                    ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    orderDetailProvider.getOrderDetail(context: context, orderId: widget.orderId);
                                  });
                                }
                              },
                              child: Container(
                                alignment: AlignmentDirectional.centerStart,
                                margin: EdgeInsetsDirectional.only(end: 5),
                                padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border?.all(color: ColorsRes.appColor, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: .start,
                                        children: [
                                          CustomTextLabel(
                                            jsonKey: deliveryBoyLabel,
                                            style: TextStyle(fontSize: 14, color: ColorsRes.grey),
                                            softWrap: true,
                                          ),
                                          getSizedBox(height: 2),
                                          CustomTextLabel(
                                            text:
                                                "${(order.deliveryBoyName == null || order.deliveryBoyName == "null" || order.deliveryBoyId == "0") ? getTranslatedValue(context, notAssignLabel) : order.deliveryBoyName}",
                                            style: TextStyle(fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            softWrap: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.arrow_drop_down),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Expanded(
                          child: Column(
                            children: [
                              if (!Constant.session.isSeller())
                                Row(
                                  children: [
                                    Expanded(
                                      child: ActionButtonWidget(
                                        buttonName: getTranslatedValue(context, callToCustomerLabel),
                                        padding: EdgeInsetsDirectional.only(bottom: 10, end: 5),
                                        voidCallback: () {
                                          launchUrlAction("tel:${order.userMobile}");
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: ActionButtonWidget(
                                        buttonName: getTranslatedValue(context, getCustomerDirectionLabel),
                                        padding: EdgeInsetsDirectional.only(bottom: 10, start: 5),
                                        voidCallback: () {
                                          launchUrlAction(
                                            "https://www.google.com/maps/dir/?api=1&destination=${order.customerLatitude},${order.customerLongitude}",
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              if (!Constant.session.isSeller())
                                Row(
                                  children: [
                                    Expanded(
                                      child: ActionButtonWidget(
                                        buttonName: getTranslatedValue(context, callToSellerLabel),
                                        padding: EdgeInsetsDirectional.only(bottom: 10, end: 5),
                                        voidCallback: () {
                                          launchUrlAction("tel:${order.sellerMobile}");
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      child: ActionButtonWidget(
                                        buttonName: getTranslatedValue(context, getSellerDirectionLabel),
                                        padding: EdgeInsetsDirectional.only(bottom: 10, start: 5),
                                        voidCallback: () {
                                          launchUrlAction(
                                            "https://www.google.com/maps/dir/?api=1&destination=${order.sellerLatitude},${order.sellerLongitude}",
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),

                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet<void>(
                                    backgroundColor: Theme.of(context).cardColor,
                                    context: context,
                                    isScrollControlled: true,
                                    shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                                    builder: (BuildContext context) {
                                      return MultiProvider(
                                        providers: [
                                          ChangeNotifierProvider(create: (context) => DeliveryBoysProvider()),
                                          ChangeNotifierProvider(create: (context) => PickupOrderUpdateStatusProvider()),
                                          ChangeNotifierProvider(
                                            create: (context) => OrderUpdateStatusProvider(),
                                          ),
                                          ChangeNotifierProvider(
                                            create: (context) => ReturnOrderUpdateStatusProvider(),
                                          ),
                                          ChangeNotifierProvider(create: (context) => OrderDetailProvider()),
                                        ],
                                        child: Consumer3<OrderUpdateStatusProvider, PickupOrderUpdateStatusProvider, ReturnOrderUpdateStatusProvider>(
                                          builder: (context, ordersProvider, pickupOrdersProvider, returnOrdersProvider, child) {
                                            // final bool isReturn = widget.from == "return";

                                            /* // Initialize the correct provider based on type
                                            if (isPickup) {
                                              if (pickupOrdersProvider.ordersStatusState == PickupOrderUpdateStatusState.initial) {
                                                pickupOrdersProvider.setSelectedStatus(
                                                  (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                );
                                                pickupOrdersProvider.getOrdersStatuses(context: context, from: "");
                                              }
                                            } else if (isReturn) {
                                              if (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.initial) {
                                                returnOrdersProvider.setSelectedStatus(
                                                  (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                );
                                                returnOrdersProvider.getOrdersStatuses(context: context, from: widget.from=="return"?"return":"");
                                              }
                                            } else {
                                              if (ordersProvider.ordersStatusState == OrderUpdateStatusState.initial) {
                                                ordersProvider.setSelectedStatus(
                                                  (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                );
                                                ordersProvider.getOrdersStatuses(context: context, from: "");
                                              }
                                            } */
                                           // Handle Normal Orders
                                            if (widget.from == "") {
                                              if (ordersProvider.ordersStatusState == OrderUpdateStatusState.initial) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  ordersProvider.setSelectedStatus(
                                                    (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                  );
                                                  ordersProvider.getOrdersStatuses(
                                                    context: context,
                                                    from: widget.from == "return" ? "return" : "",
                                                  );
                                                });
                                              }
                                            }

                                            // Handle Pickup Orders
                                            if (widget.from == "selfpickup") {
                                              if (pickupOrdersProvider.ordersStatusState == PickupOrderUpdateStatusState.initial) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  pickupOrdersProvider.setSelectedStatus(
                                                    (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                  );
                                                  pickupOrdersProvider.getOrdersStatuses(
                                                    context: context,
                                                    from: widget.from=="return"?"return":"",
                                                  );
                                                });
                                              }
                                            }

                                            // Handle Return Orders
                                            if (widget.from == "return") {
                                              if (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.initial) {
                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                  returnOrdersProvider.setSelectedStatus(
                                                    (int.parse(order.activeStatus.toString()) - 1).toString(),
                                                  );
                                                  returnOrdersProvider.getOrdersStatuses(
                                                    context: context,
                                                    from: widget.from == "return" ? "return" : "",
                                                  );
                                                });
                                              }
                                            }

                                            // UI
                                            return Container(
                                              padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
                                              child: Column(
                                                mainAxisSize: .min,
                                                children: [
                                                  Center(
                                                    child: CustomTextLabel(
                                                      jsonKey: updateOrderStatusLabel,
                                                      softWrap: true,
                                                      textAlign: TextAlign.center,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleMedium!
                                                          .merge(TextStyle(letterSpacing: 0.5, color: ColorsRes.mainTextColor)),
                                                    ),
                                                  ),
                                                  getSizedBox(height: 10),

                                                  // Status List Section
                                                  if (isPickup
                                                      ? (pickupOrdersProvider.ordersStatusState == PickupOrderUpdateStatusState.loaded ||
                                                          pickupOrdersProvider.ordersStatusState == PickupOrderUpdateStatusState.updating)
                                                      : isReturn
                                                          ? (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.loaded ||
                                                              returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.updating)
                                                          : (ordersProvider.ordersStatusState == OrderUpdateStatusState.loaded ||
                                                              ordersProvider.ordersStatusState == OrderUpdateStatusState.updating))
                                                    Column(
                                                      children: List.generate(
                                                        isPickup
                                                            ? pickupOrdersProvider.orderStatusesList.length
                                                            : isReturn
                                                                ? returnOrdersProvider.orderStatusesList.length
                                                                : ordersProvider.orderStatusesList.length,
                                                        (index) {
                                                          /* final statusText = isPickup
                                                              ? pickupOrdersProvider.orderStatusesList[index].status ?? ""
                                                              : isReturn
                                                                  ? returnOrdersProvider.orderStatusesList[index].status ?? ""
                                                                  : ordersProvider.orderStatusesList[index].status ?? ""; */

                                                          final selectedValue = isPickup
                                                              ? pickupOrdersProvider.selectedOrderStatus
                                                              : isReturn
                                                                  ? returnOrdersProvider.selectedOrderStatus
                                                                  : ordersProvider.selectedOrderStatus;

                                                          final groupValue = isPickup
                                                              ? pickupOrdersProvider.orderStatusesList[index].id
                                                              : isReturn
                                                                  ? returnOrdersProvider.orderStatusesList[index].id
                                                                  : ordersProvider.orderStatusesList[index].id;

                                                          final isDisabled = isReturn &&
                                                              returnOrdersProvider.orderStatusesList[index].isDisabled == "1";
                                                          return GestureDetector(
                                                            onTap: isDisabled ? null : () {
                                                              if (isPickup) {
                                                                pickupOrdersProvider.setSelectedStatus(index.toString());
                                                              } else if (isReturn) {
                                                                returnOrdersProvider.setSelectedStatus(index.toString());
                                                              } else {
                                                                ordersProvider.setSelectedStatus(index.toString());
                                                              }
                                                            },
                                                            child: Opacity(
                                                              opacity: isDisabled ? 0.4 : 1.0,
                                                              child: Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: Padding(
                                                                      padding: EdgeInsetsDirectional.only(start: Constant.paddingOrMargin10),
                                                                      child: CustomTextLabel(text: isPickup
                                                                                  ? pickupOrdersProvider.orderStatusesList[index].statusName!
                                                                                  : isReturn
                                                                                      ? returnOrdersProvider.orderStatusesList[index].statusName!
                                                                                      : ordersProvider.orderStatusesList[index].statusName!),
                                                                    ),
                                                                  ),
                                                                  Radio(
                                                                    activeColor: ColorsRes.appColor,
                                                                    value: selectedValue,
                                                                    groupValue: groupValue,
                                                                    onChanged: isDisabled ? null : (value) {
                                                                      if (isPickup) {
                                                                        pickupOrdersProvider.setSelectedStatus(index.toString());
                                                                      } else if (isReturn) {
                                                                        returnOrdersProvider.setSelectedStatus(index.toString());
                                                                      } else {
                                                                        ordersProvider.setSelectedStatus(index.toString());
                                                                      }
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),

                                                  getSizedBox(height: 10),

                                                  // Update Button Section
                                                  Builder(builder: (context) {
                                                    final isSameStatus = isReturn
                                                        ? returnOrdersProvider.selectedOrderStatus.toString() == order.activeStatus.toString()
                                                        : isPickup
                                                            ? pickupOrdersProvider.selectedOrderStatus.toString() == order.activeStatus.toString()
                                                            : ordersProvider.selectedOrderStatus.toString() == order.activeStatus.toString();
                                                    return AbsorbPointer(
                                                      absorbing: isSameStatus,
                                                      child: Opacity(
                                                        opacity: isSameStatus ? 0.4 : 1.0,
                                                        child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: Constant.paddingOrMargin10),
                                                    child: gradientBtnWidget(
                                                      context,
                                                      10,
                                                      callback: () {
                                                        Map<String, String> params = {};
                                                        // Check if delivered status is selected for delivery boy on normal orders
                                                        if (!Constant.session.isSeller() && !isPickup && !isReturn &&
                                                            ordersProvider.selectedOrderStatus.toString() == "6") {
                                                          showDialog(
                                                            context: context,
                                                            barrierDismissible: false,
                                                            builder: (BuildContext dialogContext) {
                                                              return DeliveryProofDialog(
                                                                orderId: widget.orderId,
                                                                deliveryBoyId: order.deliveryBoyId.toString(),
                                                                statusId: "6",
                                                                otp: orderDetailProvider.orderDetail.data?.order?.otp?.toString(),
                                                              );
                                                            },
                                                          ).then((value) {
                                                            if (value == true) {
                                                              Navigator.pop(context, value);
                                                            }
                                                          });
                                                        } else {
                                                          // Normal flow without OTP for pickup or return orders
                                                          params[ApiAndParams.orderId] = widget.orderId;
                                                          params[ApiAndParams.deliveryBoyId] = order.deliveryBoyId.toString();
                                                          if (isReturn) {
                                                            params[ApiAndParams.status] = returnOrdersProvider.selectedOrderStatus.toString();
                                                            params[ApiAndParams.id] = widget.returnOrderId.toString();
                                                          } else {
                                                            params[ApiAndParams.statusId] = isPickup
                                                                ? pickupOrdersProvider.selectedOrderStatus.toString()
                                                                : ordersProvider.selectedOrderStatus.toString();
                                                          }

                                                          if (isPickup) {
                                                            pickupOrdersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                              Navigator.pop(context, value);
                                                            });
                                                          } else if (isReturn && returnOrdersProvider.selectedOrderStatus.toString() == "7") {
                                                            // Status 7 = Cancel: ask for cancel reason first
                                                            TextEditingController cancelReasonController = TextEditingController();
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext dialogContext) {
                                                                return AlertDialog(
                                                                  backgroundColor: Theme.of(dialogContext).cardColor,
                                                                  title: CustomTextLabel(
                                                                    jsonKey: reasonLabel,
                                                                    style: Theme.of(dialogContext).textTheme.titleMedium!.merge(
                                                                      TextStyle(color: ColorsRes.mainTextColor),
                                                                    ),
                                                                  ),
                                                                  content: editBoxWidget(
                                                                    context: dialogContext,
                                                                    edtController: cancelReasonController,
                                                                    validationFunction: (_) => optionalFieldValidation("", ""),
                                                                    label: getTranslatedValue(dialogContext, reasonLabel),
                                                                    hint: getTranslatedValue(dialogContext, reasonLabel),
                                                                    inputType: TextInputType.multiline,
                                                                    maxlines: 3,
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                      onPressed: () => Navigator.of(dialogContext).pop(),
                                                                      child: Text(getTranslatedValue(dialogContext, cancelLabel)),
                                                                    ),
                                                                    ValueListenableBuilder(
                                                                      valueListenable: cancelReasonController,
                                                                      builder: (_, __, ___) => ElevatedButton(
                                                                        onPressed: cancelReasonController.text.trim().isNotEmpty
                                                                            ? () {
                                                                                Navigator.of(dialogContext).pop();
                                                                                params[ApiAndParams.cancellationReason] = cancelReasonController.text.trim();
                                                                                returnOrdersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                                                  Navigator.pop(context, value);
                                                                                });
                                                                              }
                                                                            : null,
                                                                        child: Text(getTranslatedValue(dialogContext, submitLabel)),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              },
                                                            );
                                                          } else if (isReturn) {
                                                            returnOrdersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                              Navigator.pop(context, value);
                                                            });
                                                          } else {
                                                            ordersProvider.updateOrdersStatus(params: params, context: context).then((value) {
                                                              Navigator.pop(context, value);
                                                            });
                                                          }
                                                        }
                                                      },
                                                      otherWidgets: Container(
                                                        child: (isPickup
                                                                ? (pickupOrdersProvider.ordersStatusState == PickupOrderUpdateStatusState.loaded)
                                                                : isReturn
                                                                    ? (returnOrdersProvider.ordersStatusState == ReturnOrderUpdateStatusState.loaded)
                                                                    : (ordersProvider.ordersStatusState == OrderUpdateStatusState.loaded))
                                                            ? CustomTextLabel(
                                                                jsonKey: updateOrderStatusLabel,
                                                                softWrap: true,
                                                                style: Theme.of(context)
                                                                    .textTheme
                                                                    .titleMedium!
                                                                    .merge(TextStyle(color: ColorsRes.appColorWhite, letterSpacing: 0.5)),
                                                              )
                                                            : CircularProgressIndicator(color: ColorsRes.appColorWhite),
                                                      ),
                                                    ),
                                                        ),
                                                      ),
                                                    );
                                                  }),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ).then((value) {
                                    orderDetailProvider.getOrderDetail(context: context, orderId: widget.orderId);
                                  });
                                },
                                child: Container(
                                  alignment: AlignmentDirectional.centerStart,
                                  padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin5),
                                  margin: EdgeInsetsDirectional.only(start: 5),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: ColorsRes.appColor, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: .start,
                                          children: [
                                            CustomTextLabel(
                                              jsonKey: statusLabel,
                                              style: TextStyle(color: ColorsRes.grey),
                                              softWrap: true,
                                            ),
                                            getSizedBox(height: 2),
                                            CustomTextLabel(
                                              text: order.orderStatusName ?? "",
                                              style: TextStyle(fontWeight: FontWeight.w500, color: ColorsRes.mainTextColor),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(Icons.arrow_drop_down),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (orderDetailProvider.orderDetailState == OrderDetailState.loading) {
            return ListView(
              padding: EdgeInsetsDirectional.all(10),
              children: [
                CustomTextLabel(
                  jsonKey: orderDetailsLabel,
                  style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                ),
                getSizedBox(height: 10),
                CustomShimmer(height: 90, width: double.maxFinite, borderRadius: 10),
                getSizedBox(height: 10),
                CustomTextLabel(
                  jsonKey: billingDetailsLabel,
                  style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                ),
                getSizedBox(height: 10),
                CustomShimmer(height: 220, width: double.maxFinite, borderRadius: 10),
                getSizedBox(height: 10),
                CustomTextLabel(
                  jsonKey: listOfOrderItemsLabel,
                  style: TextStyle(color: ColorsRes.appColor, fontWeight: FontWeight.w500, fontSize: 20),
                ),
                getSizedBox(height: 10),
                Column(
                  children: List.generate(
                    10,
                    (index) => CustomShimmer(height: 160, width: double.maxFinite, borderRadius: 10, margin: EdgeInsets.only(bottom: 10)),
                  ),
                ),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
      ),
    );
  }

  launchUrlAction(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      showMessage(context, '${getTranslatedValue(context, couldNotLaunchLabel)} $url', MessageType.error);
      throw '${getTranslatedValue(context, couldNotLaunchLabel)} $url';
    }
  }
}
