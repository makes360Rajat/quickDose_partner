import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getOrderDetailRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiOrderById, params: params, isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getOrderDetailRepository: ${e.toString()}");
    rethrow;
  }
}
