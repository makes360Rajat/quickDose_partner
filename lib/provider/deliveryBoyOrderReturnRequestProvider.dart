import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/deliveryBoyOrderReturnRequest.dart';



enum DeliveryBoyOrderReturnRequestState {
  initial,
  loading,
  silentLoading,
  loaded,
  empty,
  loadingMore,
  error,
}

class DeliveryBoyOrderReturnRequestProvider extends ChangeNotifier {
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  String message = '';
  DeliveryBoyOrderReturnRequestState requestState = DeliveryBoyOrderReturnRequestState.initial;

  late DeliveryBoyOrderReturnRequest returnRequest;
  List<DeliveryBoyOrderReturnRequestData> returnRequestList = [];

  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;
  int selectedStatus = 0;

  Future getDeliveryBoyOrderReturnRequests({
    required Map<String, String> params,
    required BuildContext context,
    bool? silentLoading,
  }) async {
    if (offset == 0) {
      requestState = DeliveryBoyOrderReturnRequestState.loading;
    } else {
      requestState = DeliveryBoyOrderReturnRequestState.loadingMore;
    }
    _notify();

    params[ApiAndParams.limit] = Constant.defaultDataLoadLimitAtOnce.toString();
    params[ApiAndParams.offset] = offset.toString();

    try {
      Map<String, dynamic> response = {};

      response = await getDeliveryBoyOrderReturnRequestsRepository(
        context: context,
        params: params,
      );

      if (response[ApiAndParams.status].toString() == "1") {
        returnRequest = DeliveryBoyOrderReturnRequest.fromJson(response);

        totalData = int.parse(returnRequest.total.toString());

        if (totalData > 0) {
          List<DeliveryBoyOrderReturnRequestData> tempRequests = returnRequest.data ?? [];

          returnRequestList.addAll(tempRequests);

          hasMoreData = totalData > returnRequestList.length;

          if (hasMoreData) {
            offset += Constant.defaultDataLoadLimitAtOnce;
          }
          requestState = DeliveryBoyOrderReturnRequestState.loaded;
          _notify();
        } else {
          requestState = DeliveryBoyOrderReturnRequestState.empty;
          _notify();
        }
      }
    } catch (e) {
      message = e.toString();
      showMessage(context, message, MessageType.error);
      requestState = DeliveryBoyOrderReturnRequestState.error;
      _notify();
    }
  }

  Future<bool> changeSelectedReturnRequestStatus(int index) async {
    if (selectedStatus.toString() != index.toString()) {
      selectedStatus = index;
      _notify();
      offset = 0;
      returnRequestList = [];
      return true;
    } else {
      return false;
    }
  }
}
