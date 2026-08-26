import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> updateDeliveryBoyLatLongApi(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiManageDeliveryBoysLatLong,
      params: params,
      isPost: true,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in updateDeliveryBoyLatLongApi: ${e.toString()}");
    rethrow;
  }
}
