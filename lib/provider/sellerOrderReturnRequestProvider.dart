import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/sellerOrderReturnRequest.dart';

enum SellerOrderReturnRequestState {
  initial,
  loading,
  silentLoading,
  loaded,
  empty,
  loadingMore,
  error,
}

class SellerOrderReturnRequestProvider extends ChangeNotifier {
  String message = '';
  SellerOrderReturnRequestState requestState = SellerOrderReturnRequestState.initial;

  late SellerOrderReturnRequest returnRequest;
  List<SellerOrderReturnRequestData> returnRequestList = [];

  bool hasMoreData = false;
  int totalData = 0;
  int offset = 0;
  int selectedStatus = 0;

  Future getSellerOrderReturnRequests({
    required Map<String, String> params,
    required BuildContext context,
    bool? silentLoading,
  }) async {
    if (offset == 0) {
      requestState = SellerOrderReturnRequestState.loading;
    } else {
      requestState = SellerOrderReturnRequestState.loadingMore;
    }
    notifyListeners();

    params[ApiAndParams.limit] = Constant.defaultDataLoadLimitAtOnce.toString();
    params[ApiAndParams.offset] = offset.toString();

    try {
      Map<String, dynamic> response = {};

      response = await getSellerOrderReturnRequestsRepository(
        context: context,
        params: params,
      );

      if (response[ApiAndParams.status].toString() == "1") {
        returnRequest = SellerOrderReturnRequest.fromJson(response);

        totalData = int.parse(returnRequest.total.toString());

        if (totalData > 0) {
          List<SellerOrderReturnRequestData> tempRequests = returnRequest.data ?? [];

          returnRequestList.addAll(tempRequests);

          hasMoreData = totalData > returnRequestList.length;

          if (hasMoreData) {
            offset += Constant.defaultDataLoadLimitAtOnce;
          }
          requestState = SellerOrderReturnRequestState.loaded;
          notifyListeners();
        } else {
          requestState = SellerOrderReturnRequestState.empty;
          notifyListeners();
        }
      }
    } catch (e) {
      message = e.toString();
      showMessage(context, message, MessageType.error);
      requestState = SellerOrderReturnRequestState.error;
      notifyListeners();
    }
  }

  Future<bool> changeSelectedReturnRequestStatus(int index) async {
    if (selectedStatus.toString() != index.toString()) {
      selectedStatus = index;
      notifyListeners();
      offset = 0;
      returnRequestList = [];
      return true;
    } else {
      return false;
    }
  }
}
