import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

enum CancelOrderItemState {
  initial,
  loading,
  loaded,
  error,
}

class CancelOrderItemProvider extends ChangeNotifier {
  CancelOrderItemState cancelOrderItemState = CancelOrderItemState.initial;
  String message = '';
  String status = '0';

  Future<bool> cancelOrderItem({
    required Map<String, String> params,
    required BuildContext context,
  }) async {
    try {
      cancelOrderItemState = CancelOrderItemState.loading;
      notifyListeners();

      Map<String, dynamic> response = await cancelOrderItemRepository(params: params);

      if (response[ApiAndParams.status].toString() == "1") {
        cancelOrderItemState = CancelOrderItemState.loaded;
        status = response[ApiAndParams.status].toString();
        showMessage(context, response[ApiAndParams.message], MessageType.success);
        notifyListeners();
        return true;
      } else {
        cancelOrderItemState = CancelOrderItemState.error;
        status = response[ApiAndParams.status].toString();
        showMessage(context, response[ApiAndParams.message], MessageType.warning);
        notifyListeners();
        return false;
      }
    } catch (e) {
      message = e.toString();
      status = "0";
      cancelOrderItemState = CancelOrderItemState.error;
      showMessage(context, message, MessageType.error);
      notifyListeners();
      return false;
    }
  }
}
