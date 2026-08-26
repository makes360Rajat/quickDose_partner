import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';

class ProductTranslationRepository {
  Future<Map<String, dynamic>> translateProductData({
    required BuildContext context,
    required String targetLanguage,
    required Map<String, dynamic> translationData,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        ApiAndParams.targetLanguage: targetLanguage,
      };
      translationData.forEach((key, value) {
        requestBody['data[$key]'] = value.toString();
      });

      var response = await sendApiRequest(
        apiName: ApiAndParams.apiProductAutoTranslation,
        params: requestBody,
        isPost: true,
        privacyAndTerms: true
      );

      if (response == null) {
        throw Exception('Translation API returned null response');
      }

      Map<String, dynamic> decoded;

      // If already Map
      if (response is Map<String, dynamic>) {
        decoded = response;
      } else {
        decoded = json.decode(response as String);
      }

      if (decoded.containsKey(ApiAndParams.data)) {
        final data = decoded[ApiAndParams.data];

        // If API returns List → extract first item
        if (data is List && data.isNotEmpty) {
          decoded[ApiAndParams.data] = data[0];
        }
      }

      return decoded;
    } catch (e) {
      debugPrint("Error in translateProductData: $e");
      rethrow;
    }
  }
}
