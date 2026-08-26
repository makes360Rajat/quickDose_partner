import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getSalaryApi({
  required BuildContext context,
  required Map<String, dynamic> params,
}) async {
  try {
    var response = await sendApiRequest(
      apiName: ApiAndParams.apiMySalary,
      params: params,
      isPost: false,
    );
    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getSalaryApi: ${e.toString()}");
    rethrow;
  }
}
