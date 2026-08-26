import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

enum DeliveryBoyStatusState {
  initial,
  loading,
  loaded,
  error,
}

class DeliveryBoyStatusProvider extends ChangeNotifier {
  String message = '';
  DeliveryBoyStatusState deliveryBoyState = DeliveryBoyStatusState.initial;
  String deliveryBoyStatus = "1";
  String remark = "";

  getDeliveryBoyStatusProvider({
    required BuildContext context,
  }) async {
    deliveryBoyState = DeliveryBoyStatusState.loading;
    notifyListeners();

    try {
      Map<String, dynamic> getData = (await getDeliveryBoyStatus(context: context));

      if (getData[ApiAndParams.status].toString() == "1") {
        Map<String, dynamic> statusData = getData[ApiAndParams.data];

        deliveryBoyStatus = statusData[ApiAndParams.status].toString();
        remark = statusData[ApiAndParams.remark] ?? "";

        deliveryBoyState = DeliveryBoyStatusState.loaded;
        notifyListeners();
      } else {
        deliveryBoyState = DeliveryBoyStatusState.error;
        notifyListeners();
        showMessage(context, getData[ApiAndParams.message], MessageType.warning);
      }
    } catch (e) {
      message = e.toString();
      deliveryBoyState = DeliveryBoyStatusState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
    }
  }
}
