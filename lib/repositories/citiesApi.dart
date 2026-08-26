import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getCitiesApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiCities,
      params: params,
      isPost: false,
    );

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getCitiesApi: ${e.toString()}");
    rethrow;
  }
}
