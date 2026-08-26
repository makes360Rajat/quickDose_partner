import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getWalletHistoryApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiTransaction,
      params: params,
      isPost: false,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getWalletHistoryApi: ${e.toString()}");
    rethrow;
  }
}
