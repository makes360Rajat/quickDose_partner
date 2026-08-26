import 'package:project/helper/utils/generalImports.dart';

/// Helper class for product auto-translation
/// 
/// This utility helps prepare and execute product translation requests
/// using the AI translation API
class ProductTranslationHelper {
  /// Prepare translation data from product information
  /// 
  /// Returns a map with the product fields to be translated
  static Map<String, dynamic> prepareTranslationData({
    required String name,
    required String description,
    required String? manufacturer,
    required String? metaTitle,
    required String? metaKeywords,
    required String? schemaMarkup,
    required String? metaDescription,
    required String? tags,
  }) {
    return {
      ApiAndParams.name: name,
      ApiAndParams.description: description,
      ApiAndParams.manufacturer: manufacturer ?? "",
      ApiAndParams.meta_title: metaTitle ?? "",
      ApiAndParams.meta_keywords: metaKeywords ?? "",
      ApiAndParams.schema_markup: schemaMarkup ?? "",
      ApiAndParams.meta_description: metaDescription ?? "",
      ApiAndParams.tags: tags ?? "",
    };
  }

  /// Get the default language code from the language list where is_default == "1"
  static String getDefaultLanguageCode(List<LanguageListData> languages) {
    final defaultLang = languages.firstWhere(
      (l) => l.isDefault == "1",
      orElse: () => languages.isNotEmpty ? languages.first : LanguageListData(code: "en"),
    );
    return defaultLang.code?.isNotEmpty == true ? defaultLang.code! : "en";
  }
}
