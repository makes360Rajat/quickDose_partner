import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getNotificationSettingsRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiNotificationSettings,
        params: params,
        isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getNotificationSettingsRepository: ${e.toString()}");
    return {};
  }
}

Future<Map<String, dynamic>> updateNotificationSettingsRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: ApiAndParams.apiNotificationSettingsUpdate,
        params: params,
        isPost: true);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in updateNotificationSettingsRepository: ${e.toString()}");
    rethrow;
  }
}
