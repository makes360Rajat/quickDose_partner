import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getWithdrawalRequestsApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiWithdrawalRequests,
      params: params,
      isPost: false,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getWithdrawalRequestsApi: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> sendWithdrawalRequestsApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiSendWithdrawalRequests,
      params: params,
      isPost: true,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in sendWithdrawalRequestsApi: ${e.toString()}");
    rethrow;
  }
}
