import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

Future<Map<String, dynamic>> getCategoryListRepository(
    {required Map<String, dynamic> params}) async {
  try {
    var response = await sendApiRequest(
        apiName: /* ApiAndParams.apiMainCategories */ ApiAndParams.apiSellerCategoriesList, params: params, isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getCategoryListRepository: ${e.toString()}");
    rethrow;
  }
}

Future<Map<String, dynamic>> getMainCategoryListRepository() async {
  try {
    // final sellerId = Constant.session.getData("id");
    final bool isLoggedIn = Constant.session.isUserLoggedIn();
    final String apiName = isLoggedIn
        ? ApiAndParams.apiCategories
        : "${ApiAndParams.seller}/${ApiAndParams.apiCategories}";
    var response = await sendApiRequest(
        apiName: apiName,
        params: /* sellerId.isNotEmpty ? {ApiAndParams.sellerId: sellerId} :  */{},
        isPost: false);

    return json.decode(response);
  } catch (e) {
    debugPrint("Error in getMainCategoryListRepository: ${e.toString()}");
    rethrow;
  }
}
