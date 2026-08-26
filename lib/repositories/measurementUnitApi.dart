import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getUnitsApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiUnits,
      params: params,
      isPost: false,
    );

    Map<String, dynamic> mainData = await json.decode(response);

    return mainData;
  } catch (e) {
    debugPrint("Error in getUnitsApi: ${e.toString()}");
    rethrow;
  }
}
