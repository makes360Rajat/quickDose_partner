import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getFundTransfernApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.fundTransfers,
      params: params,
      isPost: false,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getFundTransfernApi: ${e.toString()}");
    rethrow;
  }
}
