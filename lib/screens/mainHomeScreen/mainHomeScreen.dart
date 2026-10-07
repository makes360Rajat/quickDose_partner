import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project/helper/utils/awsomeNotification.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/homeMainScreenProvider.dart';

class MainHomeScreen extends StatefulWidget {
  MainHomeScreen({Key? key}) : super(key: key);

  @override
  State<MainHomeScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<MainHomeScreen> {
  NetworkStatus networkStatus = NetworkStatus.Online;
  DateTime? lastBackPressed;

  @override
  void initState() {
    checkConnectionState();
    LocalAwesomeNotification().init(context);

    Future.delayed(Duration.zero).then((value) async {
      if (!mounted) return;
      // Build initial pages
      context.read<HomeMainScreenProvider>().setPages(selectBottomMenu);

      if (Constant.session.isUserLoggedIn()) {
        // Initialize Delivery Boy Live GPS Tracking for Admin if logged in as delivery boy
        if (Constant.session.isDeliveryBoy()) {
          DeliveryBoyTrackingService.instance.init();
        }
        try {
          final String sessionFcmToken = Constant.session.getData(SessionManager.keyFCMToken);
          if (sessionFcmToken.isEmpty) {
            final String? firebaseFcmToken = await FirebaseMessaging.instance.getToken();
            if (firebaseFcmToken != null && firebaseFcmToken.isNotEmpty) {
              addFcmTokenApi(fcmToken: firebaseFcmToken).catchError((e) {
                debugPrint("Error in addFcmTokenApi: $e");
                return <String, dynamic>{};
              });
            }
          }
        } catch (_) {}

        try {
          await getNotificationSettingsRepository(params: {}).then(
            (value) async {
              if (value[ApiAndParams.status].toString() == "1") {
                late AppNotificationSettings notificationSettings =
                    AppNotificationSettings.fromJson(value);
                final isSeller = Constant.session.isSeller();
                final dataLength = notificationSettings.data?.length ?? 0;
                final maxLength = isSeller ? 11 : 8;

                if (dataLength >= 1 && dataLength <= maxLength) {
                  await updateNotificationSettingsRepository(
                    params: {
                      ApiAndParams.statusIds: (Constant.session.isSeller())?"1,2,3,4,5,6,7,8,9,10,11":"1,2,3,4,5,6,7,8",
                      ApiAndParams.mobileStatuses: (Constant.session.isSeller())?"1,1,1,1,1,1,1,1,1,1,1":"1,1,1,1,1,1,1,1",
                      ApiAndParams.mailStatuses: (Constant.session.isSeller())?"1,1,1,1,1,1,1,1,1,1,1":"1,1,1,1,1,1,1,1"
                    },
                  );
                }
              }
            },
          );
        } catch (_) {
          // Network unavailable — skip notification settings silently
        }
      }
    });

    super.initState();
  }

  //internet connection checking
  checkConnectionState() async {
    networkStatus =
        await checkInternet() ? NetworkStatus.Online : NetworkStatus.Offline;
    Connectivity().onConnectivityChanged.listen((status) {
      if (mounted) {
        setState(() {
          networkStatus = getNetworkStatus(status[0]);
        });
      }
    });
  }

  // Retry all APIs when internet connection is restored
  Future<void> retryAllAPIs() async {
    if (Constant.session.isUserLoggedIn()) {
      try {
        await getNotificationSettingsRepository(params: {}).then(
          (value) async {
            if (value[ApiAndParams.status].toString() == "1") {
              late AppNotificationSettings notificationSettings =
                  AppNotificationSettings.fromJson(value);
              final isSeller = Constant.session.isSeller();
              final dataLength = notificationSettings.data?.length ?? 0;
              final maxLength = isSeller ? 11 : 8;

              if (dataLength >= 1 && dataLength <= maxLength) {
                await updateNotificationSettingsRepository(
                  params: {
                    ApiAndParams.statusIds: (Constant.session.isSeller()) ? "1,2,3,4,5,6,7,8,9,10,11" : "1,2,3,4,5,6,7,8",
                    ApiAndParams.mobileStatuses: (Constant.session.isSeller()) ? "1,1,1,1,1,1,1,1,1,1,1" : "1,1,1,1,1,1,1,1",
                    ApiAndParams.mailStatuses: (Constant.session.isSeller()) ? "1,1,1,1,1,1,1,1,1,1,1" : "1,1,1,1,1,1,1,1"
                  },
                );
              }
            }
          },
        );

        if (mounted) {
          showMessage(
            context,
            getTranslatedValue(context, "connection_restored_successfully"),
            MessageType.success
          );
        }
      } catch (e) {
        if (mounted) {
          showMessage(
            context,
            getTranslatedValue(context, "failed_to_restore_connection"),
            MessageType.error
          );
        }
      }
    }
  }

  //change current screen based on bottom menu selection
  void selectBottomMenu(int index) {
    if (!mounted) return;
    context.read<HomeMainScreenProvider>().selectBottomMenu(index);
  }

  List<String> _getBottomMenuLabels(BuildContext context) {
    if (Constant.session.isSeller()) {
      return [
        getTranslatedValue(context, homeBottomMenuHomeLabel),
        getTranslatedValue(context, homeBottomMenuReturnLabel),
        getTranslatedValue(context, homeBottomMenuOrdersLabel),
        getTranslatedValue(context, homeBottomMenuProductsLabel),
        getTranslatedValue(context, homeBottomMenuProfileLabel),
      ];
    } else {
      return [
        getTranslatedValue(context, homeBottomMenuHomeLabel),
        getTranslatedValue(context, homeBottomMenuReturnLabel),
        getTranslatedValue(context, homeBottomMenuProfileLabel),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    print("object:${Constant.session.getData(SessionManager.appThemeName).toString()}");
    return Consumer<HomeMainScreenProvider>(
      builder: (context, homeProvider, _) {
        final lblHomeBottomMenu = _getBottomMenuLabels(context);

        return Scaffold(
          bottomNavigationBar: homeProvider.pages.isEmpty
              ? null
              : homeBottomNavigation(
                  context: context,
                  selectBottomMenu: selectBottomMenu,
                  totalPage: homeProvider.pages.length,
                  selectedIndex: homeProvider.currentPage,
                  lblHomeBottomMenu: lblHomeBottomMenu,
                ),
          body: networkStatus == NetworkStatus.Online
              ? PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, result) {
                    if (didPop) {
                      return;
                    } else {
                      if (homeProvider.currentPage != 0) {
                        homeProvider.selectBottomMenu(0);
                      } else {
                        final now = DateTime.now();
                        if (lastBackPressed == null || now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
                          lastBackPressed = now;
                          showMessage(context, getTranslatedValue(context, pressBackAgainToExitLabel), MessageType.success);
                        } else {
                          SystemNavigator.pop();
                        }
                      }
                    }
                  },
                  child: homeProvider.pages.isEmpty
                      ? const SizedBox.shrink()
                      : IndexedStack(
                          index: homeProvider.currentPage,
                          children: homeProvider.pages,
                        ),
                )
              : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      defaultImg(image: AppAssets.noInternetIcon),
                      getSizedBox(height: 30),
                      CustomTextLabel(
                        jsonKey: noInternetMessageTitleLabel,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorsRes.mainTextColor,
                        ),
                      ),
                      getSizedBox(height: 30),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 50),
                        child: gradientBtnWidget(
                          context,
                          10,
                          title: getTranslatedValue(context, tryAgainLabel),
                          callback: () async {
                            bool isConnected = await checkInternet();
                            if (isConnected) {
                              setState(() {
                                networkStatus = NetworkStatus.Online;
                              });
                              await retryAllAPIs();
                            } else {
                              showMessage(
                                context,
                                getTranslatedValue(context, noInternetMessageTitleLabel),
                                MessageType.warning
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
