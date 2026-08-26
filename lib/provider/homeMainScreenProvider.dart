import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/provider/deliveryBoyOrderReturnRequestProvider.dart';
import 'package:project/provider/sellerOrderReturnRequestProvider.dart';
import 'package:project/provider/pickupOrdersProvider.dart';
import 'package:project/screens/mainHomeScreen/orderListScreen/deliveryBoyOrderReturnRequestListScreen.dart';
import 'package:project/screens/mainHomeScreen/orderListScreen/sellerOrderReturnRequestListScreen.dart';

class HomeMainScreenProvider extends ChangeNotifier {
  int currentPage = 0;
  List<Widget> pages = [];

  // Keys per page — regenerated on language change to force full rebuild
  Key sellerHomeKey = UniqueKey();
  Key sellerReturnKey = UniqueKey();
  Key sellerOrderKey = UniqueKey();
  Key sellerProductKey = UniqueKey();
  Key sellerProfileKey = UniqueKey();

  Key deliveryHomeKey = UniqueKey();
  Key deliveryReturnKey = UniqueKey();
  Key deliveryProfileKey = UniqueKey();

  void setPages(Function(int) changeTab) {
    currentPage = 0;
    if (Constant.session.isSeller()) {
      pages = [
        MultiProvider(
          key: sellerHomeKey,
          providers: [
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: HomeScreen(changeTab: changeTab),
        ),
        ChangeNotifierProvider(
          key: sellerReturnKey,
          create: (_) => SellerOrderReturnRequestProvider(),
          child: SellerOrderReturnRequestListScreen(),
        ),
        MultiProvider(
          key: sellerOrderKey,
          providers: [
            ChangeNotifierProvider(create: (_) => SellerOrdersProvider()),
            ChangeNotifierProvider(create: (_) => SellerPickupOrdersProvider()),
          ],
          child: OrderListScreen(),
        ),
        ChangeNotifierProvider(
          key: sellerProductKey,
          create: (_) => ProductListProvider(),
          child: ProductListScreen(currentFilterIndex: 0, tabIndex: 3),
        ),
        ProfileScreen(key: sellerProfileKey),
      ];
    } else {
      pages = [
        MultiProvider(
          key: deliveryHomeKey,
          providers: [
            ChangeNotifierProvider(create: (_) => DeliveryBoyOrdersProvider()),
            ChangeNotifierProvider(create: (_) => DashboardProvider()),
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ],
          child: HomeScreen(changeTab: changeTab),
        ),
        ChangeNotifierProvider(
          key: deliveryReturnKey,
          create: (_) => DeliveryBoyOrderReturnRequestProvider(),
          child: DeliveryBoyOrderReturnRequestListScreen(),
        ),
        ProfileScreen(key: deliveryProfileKey),
      ];
    }
    notifyListeners();
  }

  /// Called after language change — generates new keys so every bottom nav
  /// page is fully rebuilt, triggering its initState and fresh API calls.
  void refreshAllPages(Function(int) changeTab) {
    sellerHomeKey = UniqueKey();
    sellerReturnKey = UniqueKey();
    sellerOrderKey = UniqueKey();
    sellerProductKey = UniqueKey();
    sellerProfileKey = UniqueKey();

    deliveryHomeKey = UniqueKey();
    deliveryReturnKey = UniqueKey();
    deliveryProfileKey = UniqueKey();

    currentPage = 0;
    setPages(changeTab);
  }

  void selectBottomMenu(int index) {
    if (index >= 0 && index < pages.length) {
      currentPage = index;
      notifyListeners();
    }
  }
}
