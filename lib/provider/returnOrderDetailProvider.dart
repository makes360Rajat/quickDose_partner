import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/returnOrderDetail.dart';

enum ReturnOrderDetailState {
  initial,
  loading,
  loaded,
  error,
}

class ReturnOrderDetailProvider extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  ReturnOrderDetailState state = ReturnOrderDetailState.initial;
  String message = '';
  ReturnOrderDetail? returnOrderDetail;

  Future<void> getReturnOrderDetail({
    required BuildContext context,
    required String returnRequestId,
  }) async {
    state = ReturnOrderDetailState.loading;
    _notify();

    try {
      final response = await getReturnOrderByIdRepository(
        returnRequestId: returnRequestId,
      );

      if (response[ApiAndParams.status].toString() == "1") {
        returnOrderDetail = ReturnOrderDetail.fromJson(response);
        state = ReturnOrderDetailState.loaded;
      } else {
        message = response[ApiAndParams.message]?.toString() ?? "";
        state = ReturnOrderDetailState.error;
        if (context.mounted) showMessage(context, message, MessageType.error);
      }
    } catch (e) {
      message = e.toString();
      state = ReturnOrderDetailState.error;
      if (context.mounted) showMessage(context, message, MessageType.error);
    }

    _notify();
  }
}
