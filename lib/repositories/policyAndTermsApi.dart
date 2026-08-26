
import 'dart:convert';

import 'package:project/helper/utils/apiAndParams.dart';
import 'package:project/helper/utils/constant.dart';
import 'package:project/helper/utils/generalMethods.dart';


Future<Map<String, dynamic>> fetchPolicyAndTerms() async {
  try {
    final result = await sendApiRequest(
      apiName: ApiAndParams.apiPolicies,
      params: {ApiAndParams.isSeller: Constant.session.isSeller() ? "1" : "0"},
      isPost: false,
      privacyAndTerms: false
    );

    return json.decode(result);
  } catch (e) {
    return {"message": e.toString()};
  }
}