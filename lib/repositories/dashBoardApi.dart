import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getDashboardRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiDashboard, params: params, isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getDashboardRepository: ${e.toString()}");
    rethrow;
  }
}
