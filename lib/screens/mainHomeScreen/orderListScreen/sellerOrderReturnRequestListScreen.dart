import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/sellerOrderReturnRequestProvider.dart';
import 'package:project/screens/mainHomeScreen/orderListScreen/widget/sellerOrderReturnRequestContainer.dart';
import 'package:project/screens/mainHomeScreen/orderListScreen/widget/orderTypeButtonWidget.dart';

class SellerOrderReturnRequestListScreen extends StatefulWidget {
  const SellerOrderReturnRequestListScreen({Key? key}) : super(key: key);

  @override
  State<SellerOrderReturnRequestListScreen> createState() => _SellerOrderReturnRequestListScreenState();
}

class _SellerOrderReturnRequestListScreenState extends State<SellerOrderReturnRequestListScreen> {
  late ScrollController scrollController = ScrollController();
  List<String> lblOrderStatusDisplayNames = [];
  List<String> lblOrderStatusUpdateNames = [];
  TextEditingController searchController = TextEditingController();

  String startDate = "";
  String endDate = "";
  Timer? _searchDebounce;
  int currentTabIndex = 0;

  scrollListener() {
    // nextPageTrigger will have a value equivalent to 70% of the list size.
    var nextPageTrigger = 0.7 * scrollController.position.maxScrollExtent;

// _scrollController fetches the next paginated data when the current position of the user on the screen has surpassed
    if (scrollController.position.pixels > nextPageTrigger) {
      if (mounted) {
        if (context.read<SellerOrderReturnRequestProvider>().hasMoreData &&
            context.read<SellerOrderReturnRequestProvider>().requestState !=
                SellerOrderReturnRequestState.loadingMore) {
          callApi(reset: false);
        }
      }
    }
  }

  Future callApi({bool? reset, bool? isSilentLoading}) async {
    if (reset == true) {
      resetDate();
      context.read<SellerOrderReturnRequestProvider>().offset = 0;
      context.read<SellerOrderReturnRequestProvider>().returnRequestList.clear();
    }

    Map<String, String> params = {};
    params[ApiAndParams.isCompleted] = currentTabIndex == 0 ? "0" : "1";
    if (isDateRangeValidate()) {
      params[ApiAndParams.startDate] = startDate;
      params[ApiAndParams.endDate] = endDate;
    }

    params[ApiAndParams.search] = searchController.text.toString();

    await context.read<SellerOrderReturnRequestProvider>().getSellerOrderReturnRequests(
        context: context,
        params: params,
        silentLoading: isSilentLoading == true);
  }

  bool isDateRangeValidate() {
    return (startDate != getTranslatedValue(context, startDateLabel) &&
        endDate != getTranslatedValue(context, endDateLabel) && startDate.trim() != "" && endDate.trim() != "");
  }

  resetDate() {
    startDate = getTranslatedValue(context, startDateLabel);
    endDate = getTranslatedValue(context, endDateLabel);
  }

  @override
  void initState() {
    Map<String, String> params = {};
    params[ApiAndParams.status] = "1";

    Future.delayed(
      Duration.zero,
      () {
        startDate = getTranslatedValue(context, startDateLabel);
        endDate = getTranslatedValue(context, endDateLabel);

        lblOrderStatusDisplayNames = [
          getTranslatedValue(context, orderReturnStatusDisplayNamesPendingLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesApprovedLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesRejectedLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesDeliveryBoyAssignedLabel),/* 
          getTranslatedValue(context, orderReturnStatusDisplayNamesOutForPickupLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesReceivedFromCustomerLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesCancelledLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesReturnToSellerLabel), */

        ];

        lblOrderStatusUpdateNames = [
          getTranslatedValue(context, orderReturnStatusDisplayNamesPendingLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesApprovedLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesRejectedLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesDeliveryBoyAssignedLabel),/* 
          getTranslatedValue(context, orderReturnStatusDisplayNamesOutForPickupLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesReceivedFromCustomerLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesCancelledLabel),
          getTranslatedValue(context, orderReturnStatusDisplayNamesReturnToSellerLabel), */

        ];

        callApi(reset: true);

        searchController.addListener(() {
          if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
          _searchDebounce = Timer(const Duration(milliseconds: 500), () async {
            await callApi(reset: true);
            if (mounted) setState(() {});
          });
        });

        scrollController.addListener(scrollListener);
      },
    );
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lblOrderStatusDisplayNames.isEmpty) {
      lblOrderStatusDisplayNames = [
        getTranslatedValue(context, orderReturnStatusDisplayNamesPendingLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesApprovedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesRejectedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesDeliveryBoyAssignedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesOutForPickupLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesReceivedFromCustomerLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesCancelledLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesReturnToSellerLabel),
      ];
    }
    if (lblOrderStatusDisplayNames.isEmpty) {
      lblOrderStatusDisplayNames = [
        getTranslatedValue(context, orderReturnStatusDisplayNamesPendingLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesApprovedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesRejectedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesDeliveryBoyAssignedLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesOutForPickupLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesReceivedFromCustomerLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesCancelledLabel),
        getTranslatedValue(context, orderReturnStatusDisplayNamesReturnToSellerLabel),
      ];
    }

    return Scaffold(
      appBar: getAppBar(
        context: context,
        title: CustomTextLabel(
          jsonKey: orderReturnRequestLabel,
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).cardColor,
            padding: EdgeInsetsDirectional.all(10),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (currentTabIndex != 0) {
                        setState(() => currentTabIndex = 0);
                        callApi(reset: true);
                      }
                    },
                    child: OrderTypeButtonWidget(
                      isActive: currentTabIndex == 0,
                      child: Center(
                        child: CustomTextLabel(
                          jsonKey: activeOrdersLabel,
                          softWrap: true,
                          style: TextStyle(
                            color: currentTabIndex == 0
                                ? ColorsRes.appColorWhite
                                : ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (currentTabIndex != 1) {
                        setState(() => currentTabIndex = 1);
                        callApi(reset: true);
                      }
                    },
                    child: OrderTypeButtonWidget(
                      isActive: currentTabIndex == 1,
                      child: Center(
                        child: CustomTextLabel(
                          jsonKey: previousOrdersLabel,
                          softWrap: true,
                          style: TextStyle(
                            color: currentTabIndex == 1
                                ? ColorsRes.appColorWhite
                                : ColorsRes.mainTextColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          getSizedBox(height: 10),
          Row(
            crossAxisAlignment: .center,
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(start: 10),
                  child: editBoxWidget(
                    maxlines: 1,
                    context: context,
                    edtController: searchController,
                    validationFunction: (value)=> optionalFieldValidation("",  ""),
                    label: getTranslatedValue(context, searchLabel),
                    hint: getTranslatedValue(context, searchLabel),
                    bgcolor: Theme.of(context).cardColor,
                    inputType: TextInputType.text,
                    tailIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: ColorsRes.mainTextColor,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              getSizedBox(width: 10),
              /* isDateRangeValidate()? */Container(
                padding: EdgeInsetsDirectional.all(10),
                decoration: BoxDecoration(
                  color: ColorsRes.appColorLightHalfTransparent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                child: GestureDetector(
                  onTap: () {
                    showDateRangePicker(
                      context: context,
                      firstDate: DateTime(DateTime.now().year - 100, 1, 1),
                      lastDate: DateTime.now(),
                      currentDate: DateTime.now(),
                      keyboardType: TextInputType.datetime,
                      initialEntryMode: DatePickerEntryMode.calendarOnly,
                      builder: (context, child) {
                        return Localizations(
                          locale: Locale(
                            Constant.session.getData(SessionManager.keySelectedLanguageCode).isNotEmpty
                                ? Constant.session.getData(SessionManager.keySelectedLanguageCode)
                                : 'en',
                          ),
                          delegates: const [
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate,
                          ],
                          child: Theme(
                            data: Constant.session
                                    .getBoolData(SessionManager.isDarkTheme)
                                ? ThemeData.dark().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: ColorsRes.appColor,
                                      onPrimary: ColorsRes.mainTextColor,
                                      surface: Theme.of(context).cardColor,
                                      inverseSurface: ColorsRes.subTitleTextColor,
                                      onSurface: ColorsRes.mainTextColor,
                                      secondary: ColorsRes.appColor,
                                    ),
                                    visualDensity: VisualDensity.compact, dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).cardColor),
                                  )
                                : ThemeData.light().copyWith(
                                    colorScheme: ColorScheme.dark(
                                      primary: ColorsRes.appColor,
                                      onPrimary: ColorsRes.mainTextColor,
                                      surface: Theme.of(context).cardColor,
                                      onSurface: ColorsRes.mainTextColor,
                                      inverseSurface: ColorsRes.subTitleTextColor,
                                      secondary: ColorsRes.appColor,
                                    ),
                                    visualDensity: VisualDensity.compact, dialogTheme: DialogThemeData(backgroundColor: Theme.of(context).cardColor),
                                  ),
                            child: child!,
                          ),
                        );
                      },
                    ).then(
                      (value) {
                        if (value != null) {
                          startDate = value.start.toString().split(" ")[0];
                          endDate = value.end.toString().split(" ")[0];

                          context.read<SellerOrderReturnRequestProvider>().offset = 0;
                          context
                              .read<SellerOrderReturnRequestProvider>()
                              .returnRequestList
                              .clear();

                          setState(() {});
                          callApi();
                        }
                      },
                    );
                  },
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: ColorsRes.appColor,
                  ),
                ),
              )/* :const SizedBox.shrink() */,
              getSizedBox(width: 10),
            ],
          ),
          if (isDateRangeValidate())
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: 10,
                end: 10,
                top: 10,
              ),
              child: Container(
                padding: EdgeInsetsDirectional.all(
                    (!isDateRangeValidate()) ? 12 : 14),
                decoration: BoxDecoration(
                  border: Border.all(color: ColorsRes.subTitleTextColor),
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: .center,
                  children: [
                    Expanded(
                      child: CustomTextLabel(
                        text:
                            "$startDate\t\t${getTranslatedValue(context, toLabel)}\t\t$endDate",
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    getSizedBox(width: 10),
                    if (isDateRangeValidate())
                      GestureDetector(
                        onTap: () {
                          callApi(reset: true);
                          setState(() {});
                        },
                        child: CustomTextLabel(
                          jsonKey: clearLabel,
                          style: TextStyle(
                            color: ColorsRes.appColorRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          getSizedBox(height: 10),
          Consumer<SellerOrderReturnRequestProvider>(
            builder: (context, ordersProvider, child) {
              if (ordersProvider.requestState == SellerOrderReturnRequestState.loaded ||
                  ordersProvider.requestState == SellerOrderReturnRequestState.loadingMore ||
                  ordersProvider.requestState ==
                      SellerOrderReturnRequestState.silentLoading) {
                return Expanded(
                  child: setRefreshIndicator(
                    refreshCallback: () {
                      return callApi(reset: true);
                    },
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      controller: scrollController,
                      itemCount: ordersProvider.returnRequestList.length,
                      itemBuilder: (context, index) {
                        if (index ==
                            ordersProvider.returnRequestList.length - 1) {
                          if (ordersProvider.requestState ==
                              SellerOrderReturnRequestState.loadingMore) {
                            return OrderContainerShimmer(context);
                          }
                        }
                        return SellerOrderReturnRequestContainer(
                          order: ordersProvider.returnRequestList[index],
                          index: index.toString(),
                          lblOrderStatusDisplayNames:
                              lblOrderStatusDisplayNames,
                          lblOrderStatusUpdateNames: lblOrderStatusUpdateNames,
                          callApi: () =>
                              callApi(reset: true, isSilentLoading: true),
                        );
                      },
                    ),
                  ),
                );
              } else if (ordersProvider.requestState ==
                  SellerOrderReturnRequestState.loading) {
                return Expanded(
                  child: setRefreshIndicator(
                    refreshCallback: () {
                      return callApi(reset: true);
                    },
                    child: ListView.builder(
                      physics: ClampingScrollPhysics(),
                      controller: scrollController,
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        return OrderContainerShimmer(context);
                      },
                    ),
                  ),
                );
              } else if (ordersProvider.requestState ==
                  SellerOrderReturnRequestState.empty) {
                return Expanded(
                  child: DefaultBlankItemMessageScreen(
                    image: "no_order_icon",
                    title: emptyOrdersMessageLabel,
                    description: emptyOrdersDescriptionLabel,
                    buttonTitle: refreshLabel,
                    callback: () async {
                      return callApi();
                    },
                  ),
                );
              } else {
                return Expanded(
                  child: DefaultBlankItemMessageScreen(
                    image: "something_went_wrong",
                    title: somethingWentWrongMessageTitleLabel,
                    description:somethingWentWrongMessageDescriptionLabel,
                    buttonTitle: tryAgainLabel,
                    callback: () async {
                      return callApi(reset: true);
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
