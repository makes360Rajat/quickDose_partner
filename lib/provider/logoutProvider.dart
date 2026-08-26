import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

enum LogoutState {
  initial,
  loading,
  loaded,
  error,
}

class LogoutProvider extends ChangeNotifier {
  LogoutState logoutState = LogoutState.initial;
  String message = '';

  Future<void> logoutApiProvider({required BuildContext context}) async {
    try {
      logoutState = LogoutState.loading;
      notifyListeners();

      await logoutApiRepository(
        fcmToken: Constant.session.getData(SessionManager.keyFCMToken),
      );

      logoutState = LogoutState.loaded;
      notifyListeners();
    } catch (e) {
      message = e.toString();
      logoutState = LogoutState.error;
      notifyListeners();
    }
  }
}
