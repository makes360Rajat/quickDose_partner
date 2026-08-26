import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/repositories/productTranslationApi.dart';

enum ProductTranslationState {
  initial,
  loading,
  loaded,
  error,
}

class ProductTranslationProvider extends ChangeNotifier {
  final ProductTranslationRepository repository;

  ProductTranslationProvider({required this.repository});

  ProductTranslationState state = ProductTranslationState.initial;
  Map<String, dynamic> translatedData = {};
  String message = '';

  /// Translate product data to target language
  /// 
  /// Parameters:
  /// - [targetLanguage]: Target language code (e.g., "en", "es", "fr")
  /// - [translationData]: Map containing product fields to translate like:
  ///   {
  ///     "name": "tomato english",
  ///     "description": "<p>tomato english </p>",
  ///     "manufacturer": "tomato english",
  ///     "meta_title": "tomato english",
  ///     "meta_keywords": "tomato english",
  ///     "schema_markup": "tomato english",
  ///     "meta_description": "tomato english",
  ///     "tags": "Fresh Capsicum"
  ///   }
  /// - [context]: BuildContext for showing messages
  /// 
  /// Returns: [bool] - true if translation was successful, false otherwise
  Future<bool> translateProduct({
    required String targetLanguage,
    required Map<String, dynamic> translationData,
    required BuildContext context,
  }) async {
    state = ProductTranslationState.loading;
    notifyListeners();

    try {
      var response = await repository.translateProductData(
        context: context,
        targetLanguage: targetLanguage,
        translationData: translationData,
      );

      Map<String, dynamic> responseMap = response;

      if (responseMap[ApiAndParams.status].toString() == "1") {
        // Store the translated data from the response
        if (responseMap.containsKey(ApiAndParams.data)) {
          translatedData = responseMap[ApiAndParams.data];
        }

        showMessage(context, responseMap[ApiAndParams.message], MessageType.success);
        state = ProductTranslationState.loaded;
        notifyListeners();
        return true;
      } else {
        message = responseMap[ApiAndParams.message] ?? "Translation failed";
        showMessage(context, message, MessageType.warning);
        state = ProductTranslationState.error;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint("Error in translateProduct: $e");
      message = e.toString();
      showMessage(context, message, MessageType.error);
      state = ProductTranslationState.error;
      notifyListeners();
      return false;
    }
  }

  /// Get translated data for a specific field
  String getTranslatedField(String fieldName) {
    return translatedData[fieldName]?.toString() ?? '';
  }

  /// Clear the translation state
  void clearTranslation() {
    state = ProductTranslationState.initial;
    translatedData = {};
    message = '';
    notifyListeners();
  }
}
