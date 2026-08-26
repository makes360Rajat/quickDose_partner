import 'package:flutter/material.dart';
import 'package:project/helper/utils/apiAndParams.dart';
import 'package:project/helper/utils/generalMethods.dart';
import 'package:project/models/productDetail.dart';
import 'package:project/repositories/addProductApi.dart';

enum ProductDetailViewState { initial, loading, loaded, error }

class ProductDetailViewProvider extends ChangeNotifier {
  ProductDetailViewState state = ProductDetailViewState.initial;
  ProductDetailData? productDetailData;
  String message = '';

  Future<void> fetchProductDetail({
    required String productId,
    required BuildContext context,
  }) async {
    try {
      state = ProductDetailViewState.loading;
      notifyListeners();

      final result = await getProductById(
        context: context,
        params: {ApiAndParams.productId: productId},
      );

      if (result[ApiAndParams.status].toString() == '1') {
        final detail = ProductDetail.fromJson(result);
        productDetailData = detail.data;
        state = ProductDetailViewState.loaded;
      } else {
        message = result[ApiAndParams.message].toString();
        state = ProductDetailViewState.error;
        showMessage(context, message, MessageType.error);
      }
    } catch (e) {
      message = e.toString();
      state = ProductDetailViewState.error;
      showMessage(context, message, MessageType.error);
    }
    notifyListeners();
  }
}
