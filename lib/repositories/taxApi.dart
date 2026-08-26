import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getTaxApi(
    {required BuildContext context,
    required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiTaxes,
      params: params,
      isPost: false,
    );

    Map<String, dynamic> mainData = await json.decode(response);

    return mainData;
  } catch (e) {
    debugPrint("Error in getTaxApi: ${e.toString()}");
    rethrow;
  }
}
