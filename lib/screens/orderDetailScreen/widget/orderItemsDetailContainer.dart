import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/orderDetail.dart';

getOrderItemDetailsContainer(
    {required BuildContext context,
    OrderItems? orderItem,
    VoidCallback? onCancelSuccess}) {
  double price = double.parse(orderItem?.price ?? "0.0");
  double? discountedPrice = double.parse(orderItem?.discountedPrice ?? "0.0");
  return ChangeNotifierProvider(
    create: (_) => CancelOrderItemProvider(),
    child: Consumer<CancelOrderItemProvider>(
      builder: (context, cancelProvider, _) {
        return Container(
          padding: EdgeInsets.all(Constant.paddingOrMargin10),
          margin: EdgeInsetsDirectional.only(
            bottom: Constant.paddingOrMargin10,
          ),
          decoration: DesignConfig.boxDecoration(
            Theme.of(context).cardColor,
            10,
          ),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              Row(mainAxisAlignment: .start, crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: CustomTextLabel(
                      text: "${orderItem?.productName} (${orderItem?.variantName})",
                      softWrap: true,
                      style: TextStyle(
                        color: ColorsRes.mainTextColor,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (orderItem?.activeStatus == "7")
                    CustomTextLabel(
                    jsonKey: orderStatusDisplayNamesCancelledLabel,
                    softWrap: true,
                    style: TextStyle(
                      color: ColorsRes.appColorRed,
                      fontSize: 15,
                    ),
                  ),
                  if (Constant.session.isSeller() && orderItem?.activeStatus != "7" && orderItem?.activeStatus != "6" && orderItem?.activeStatus != "8" && orderItem?.activeStatus != "11")
                    GestureDetector(
                      onTap: cancelProvider.cancelOrderItemState == CancelOrderItemState.loading
                          ? null
                          : () {
                              showDialog(
                                context: context,
                                builder: (dialogContext) {
                                  final reasonController = TextEditingController();
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
                                      edtController: reasonController,
                                      validationFunction: (value) => emptyValidation(value, getTranslatedValue(context, enterCancellationReasonLabel)),
                                      label: getTranslatedValue(dialogContext, cancellationReasonLabel),
                                      hint: getTranslatedValue(dialogContext, enterCancellationReasonLabel),
                                      inputType: TextInputType.multiline,
                                      maxlines: 3,
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(dialogContext).pop(),
                                        child: Text(getTranslatedValue(dialogContext, cancelLabel), style: TextStyle(color: ColorsRes.mainTextColor)),
                                      ),
                                      ValueListenableBuilder(
                                        valueListenable: reasonController,
                                        builder: (_, __, ___) => ElevatedButton(
                                          onPressed: reasonController.text.trim().isNotEmpty
                                              ? () {
                                                  Navigator.of(dialogContext).pop();
                                                  final params = {
                                                    ApiAndParams.orderItemId: orderItem?.id ?? "",
                                                    ApiAndParams.cancellationReason: reasonController.text.trim(),
                                                  };
                                                  cancelProvider
                                                      .cancelOrderItem(params: params, context: context)
                                                      .then((success) {
                                                    if (success && onCancelSuccess != null) {
                                                      onCancelSuccess();
                                                    }
                                                  });
                                                }
                                              : null,
                                          child: Text(getTranslatedValue(dialogContext, submitLabel), style: TextStyle(color: ColorsRes.appColor)),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                      child: cancelProvider.cancelOrderItemState == CancelOrderItemState.loading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ColorsRes.appColorRed,
                              ),
                            )
                          : Container(
                              padding: EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: ColorsRes.appColorRed.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: ColorsRes.appColorRed, width: 1),
                              ),
                              child: CustomTextLabel(
                                jsonKey: cancelLabel,
                                softWrap: true,
                                style: TextStyle(
                                  color: ColorsRes.appColorRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                    ),
                ],
              ),
              getSizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      child: setNetworkImg(
                        image: orderItem?.image.toString() ?? "",
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
                            value: orderItem?.quantity.toString() ?? "1"),
                        getSizedBox(
                          height: 5,
                        ),
                        getOrderDetailContainer(
                          title: getTranslatedValue(context, priceLabel),
                          value: getCurrencyFormat(discountedPrice.compareTo(0.0) == 0
                              ? price
                              : discountedPrice),
                        ),
                        getSizedBox(
                          height: 5,
                        ),
                        getOrderDetailContainer(
                          title: getTranslatedValue(context, taxLabel),
                          value: "${getCurrencyFormat(
                            (double.parse(orderItem?.taxAmount ?? "0.0")) *
                                (double.parse(orderItem?.quantity ?? "1")),
                          )} (Qty x ${orderItem?.taxPercentage ?? 0.0}% Tax)",
                        ),
                        getSizedBox(
                          height: 5,
                        ),
                        getOrderDetailContainer(
                          title: getTranslatedValue(context, subtotalLabel),
                          value: getCurrencyFormat(
                              double.parse(orderItem?.subTotal ?? "0.0")),
                        ),
                        if (orderItem?.activeStatus == "7")
                          Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "${getTranslatedValue(context, cancellationReasonLabel)}: ",
                                      style: TextStyle(color: ColorsRes.appColorRed, fontWeight: FontWeight.w600, fontSize: 14),
                                    ),
                                    TextSpan(
                                      text: "${orderItem!.cancellationReason ?? ""}",
                                      style: TextStyle(color: ColorsRes.appColorRed, fontWeight: FontWeight.normal, fontSize: 14),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    ),
  );
}
