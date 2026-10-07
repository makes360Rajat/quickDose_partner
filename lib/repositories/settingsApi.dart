import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future/* <Map<String, dynamic>> */ getAppSettingsRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiAppSettings, params: params, isPost: false);

    if (response == null || response is! String || response.isEmpty) {
      return <String, dynamic>{};
    }

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getAppSettingsRepository: ${e.toString()}");
    return <String, dynamic>{};
  }
}
