import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future/* <Map<String, dynamic>> */ getAppSettingsRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAppSettings, params: params, isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getAppSettingsRepository: ${e.toString()}");
    rethrow;
  }
}
