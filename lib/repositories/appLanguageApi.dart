import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getSystemLanguageApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiSystemLanguages,
      params: params,
      isPost: false,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getSystemLanguageApi: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getAvailableLanguagesApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiSystemLanguages,
      params: params,
      isPost: false,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getAvailableLanguagesApi: ${e.toString()}");
    rethrow;
  }
}
