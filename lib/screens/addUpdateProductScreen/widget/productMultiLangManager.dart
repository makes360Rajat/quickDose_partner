import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/helper/utils/productTranslationHelper.dart';
import 'package:project/provider/productTranslationProvider.dart';

/// Holds translatable field values for a single language.
class LanguageTranslationData {
  String name;
  String manufacturer;
  String description;
  String metaTitle;
  String metaKeywords;
  String schemaMarkup;
  String metaDescription;
  String tags;

  LanguageTranslationData({
    this.name = '',
    this.manufacturer = '',
    this.description = '',
    this.metaTitle = '',
    this.metaKeywords = '',
    this.schemaMarkup = '',
    this.metaDescription = '',
    this.tags = '',
  });
}

/// Manages all multilanguage logic for the product add/update screen.
///
/// Centralises:
///  - Per-language field snapshots ([translationMap])
///  - Save / restore field values when the user switches language chips
///  - Language-chip row widget ([buildLanguageChipsWidget])
///  - Auto-translate button widget ([buildAutoTranslateButton])
///  - Encoding the `translations` JSON param for API calls ([buildTranslationsJson])
class ProductMultiLangManager {
  // ── Mutable state ──────────────────────────────────────────────────────

  /// Per-language snapshot of all translatable product fields.
  Map<String, LanguageTranslationData> translationMap = {};

  /// The `adminLangIdForFcm` of the currently selected language chip.
  String selectedLanguageId = "";

  /// True while an auto-translation request is in flight.
  bool isTranslating = false;

  // ── Injected dependencies ──────────────────────────────────────────────

  final BuildContext Function() _getContext;
  final bool Function() _isMounted;

  /// Call this to trigger a setState on the parent screen.
  final VoidCallback _onStateChanged;

  // Text-controller getters — lambdas so they always return the *current*
  // instance even when the parent screen re-assigns the controllers in callApi.
  final TextEditingController Function() getName;
  final TextEditingController Function() getManufacturer;
  final TextEditingController Function() getMetaTitle;
  final TextEditingController Function() getMetaKeywords;
  final TextEditingController Function() getSchemaMarkup;
  final TextEditingController Function() getMetaDescription;

  /// Returns the current HTML description string stored in the parent state.
  final String Function() getHtmlDescription;

  /// Updates the HTML description string in the parent state.
  final void Function(String) setHtmlDescription;

  /// Returns the currently selected tags list from the parent state.
  final List<TagsData> Function() getSelectedTags;

  ProductMultiLangManager({
    required BuildContext Function() contextRef,
    required bool Function() isMounted,
    required VoidCallback onStateChanged,
    required this.getName,
    required this.getManufacturer,
    required this.getMetaTitle,
    required this.getMetaKeywords,
    required this.getSchemaMarkup,
    required this.getMetaDescription,
    required this.getHtmlDescription,
    required this.setHtmlDescription,
    required this.getSelectedTags,
  })  : _getContext = contextRef,
        _isMounted = isMounted,
        _onStateChanged = onStateChanged;

  BuildContext get _ctx => _getContext();

  // ── Computed properties ────────────────────────────────────────────────

  /// True when more than one language is configured in the app.
  bool get isMultiLanguage {
    final langs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
    return langs.length > 1;
  }

  /// True when the currently active chip is the default language,
  /// or when only one language is configured (no chips shown).
  bool get isDefaultLanguageSelected {
    if (!isMultiLanguage) return true;
    final langs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
    final defaultLang = langs.firstWhere(
      (l) => l.isDefault == "1",
      orElse: () => langs.first,
    );
    return selectedLanguageId == (defaultLang.adminLangIdForFcm ?? "");
  }

  /// Returns the translated label for [baseKey], appending "(LanguageName)"
  /// when multiple languages are configured and a non-default chip is active.
  String fieldLabel(String baseKey) {
    if (!isMultiLanguage || selectedLanguageId.isEmpty) {
      return getTranslatedValue(_ctx, baseKey);
    }
    final langs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
    final selectedLang = langs.firstWhere(
      (l) => l.adminLangIdForFcm == selectedLanguageId,
      orElse: () => LanguageListData(),
    );
    if (selectedLang.isDefault == "1") {
      return getTranslatedValue(_ctx, baseKey);
    }
    return "${getTranslatedValue(_ctx, baseKey)} (${selectedLang.name ?? ""})";
  }

  // ── Core save / load ───────────────────────────────────────────────────

  /// Snapshots the current field values into [translationMap] under
  /// [selectedLanguageId].
  void saveCurrentLanguageData() {
    if (selectedLanguageId.isEmpty) return;

    final existing = translationMap[selectedLanguageId];

    final merged = LanguageTranslationData(
      name: getName().text.isNotEmpty ? getName().text : (existing?.name ?? ""),
      manufacturer: getManufacturer().text.isNotEmpty ? getManufacturer().text : (existing?.manufacturer ?? ""),
      description: getHtmlDescription().isNotEmpty ? getHtmlDescription() : (existing?.description ?? ""),
      metaTitle: getMetaTitle().text.isNotEmpty ? getMetaTitle().text : (existing?.metaTitle ?? ""),
      metaKeywords: getMetaKeywords().text.isNotEmpty ? getMetaKeywords().text : (existing?.metaKeywords ?? ""),
      schemaMarkup: getSchemaMarkup().text.isNotEmpty ? getSchemaMarkup().text : (existing?.schemaMarkup ?? ""),
      metaDescription: getMetaDescription().text.isNotEmpty ? getMetaDescription().text : (existing?.metaDescription ?? ""),
      tags: getSelectedTags().isNotEmpty ? getSelectedTags().map((t) => t.name ?? "").join(',') : (existing?.tags ?? ""),
    );

    final hasData = merged.name.isNotEmpty ||
        merged.manufacturer.isNotEmpty ||
        merged.description.isNotEmpty ||
        merged.metaTitle.isNotEmpty ||
        merged.metaKeywords.isNotEmpty ||
        merged.schemaMarkup.isNotEmpty ||
        merged.metaDescription.isNotEmpty ||
        merged.tags.isNotEmpty;

    if (hasData || existing == null) {
      translationMap[selectedLanguageId] = merged;
      debugPrint('Saved translation for $selectedLanguageId: ${merged.name}');
    } else {
      debugPrint('Skipped saving empty translation for $selectedLanguageId (preserving existing)');
    }
  }

  /// Restores field values from [translationMap] for [langId].
  /// Clears the fields when no saved data exists yet for that language.
  void loadLanguageData(String langId) {
    // Try several fallback keys to handle API id / code / admin-id mismatches.
    String? matchedKey;
    LanguageTranslationData? trans;

    // 1. Direct lookup by passed langId (typically adminLangIdForFcm).
    if (translationMap.containsKey(langId)) {
      matchedKey = langId;
      trans = translationMap[langId];
    } else {
      // 2. Try the language's numeric id and code as fallback keys.
      final langs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
      final langEntry = langs.firstWhere(
        (l) => l.adminLangIdForFcm == langId,
        orElse: () => LanguageListData(),
      );
      final possibleKeys = <String>[];
      if ((langEntry.id ?? "").isNotEmpty) possibleKeys.add(langEntry.id!);
      if ((langEntry.code ?? "").isNotEmpty) possibleKeys.add(langEntry.code!);

      for (var k in possibleKeys) {
        if (translationMap.containsKey(k)) {
          matchedKey = k;
          trans = translationMap[k];
          break;
        }
      }
    }

    getName().text = trans?.name ?? "";
    getManufacturer().text = trans?.manufacturer ?? "";
    getMetaTitle().text = trans?.metaTitle ?? "";
    getMetaKeywords().text = trans?.metaKeywords ?? "";
    getSchemaMarkup().text = trans?.schemaMarkup ?? "";
    getMetaDescription().text = trans?.metaDescription ?? "";
    setHtmlDescription(trans?.description ?? "");

    debugPrint('Loading language data for langId=$langId matchedKey=$matchedKey');

    if (_isMounted()) _onStateChanged();
  }

  // ── Init helpers ───────────────────────────────────────────────────────

  /// Picks and activates the default language on screen init.
  void setDefaultLanguage(List<LanguageListData> languages) {
    if (languages.isNotEmpty && selectedLanguageId.isEmpty) {
      final defaultLang = languages.firstWhere(
        (l) => l.isDefault == "1",
        orElse: () => languages.first,
      );
      selectedLanguageId = defaultLang.adminLangIdForFcm ?? "";
      _onStateChanged();
      // Snapshot whatever fields are already populated (edit mode).
      saveCurrentLanguageData();
      // Reload UI when product data was already present before language list arrived.
      if (translationMap.isNotEmpty) {
        loadLanguageData(defaultLang.adminLangIdForFcm ?? "");
      }
    }
  }

  // ── Translation helpers ────────────────────────────────────────────────

  /// Stores AI-translated data (from the translation API response) into
  /// [translationMap], keyed by each language's adminLangIdForFcm.
  void applyTranslatedData(Map<String, dynamic> allTranslations) {
    final langs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
    allTranslations.forEach((langCode, fields) {
      if (fields is! Map<String, dynamic>) return;
      final lang = langs.firstWhere(
        (l) => l.code == langCode,
        orElse: () => LanguageListData(),
      );
      final langId = lang.adminLangIdForFcm ?? "";
      if (langId.isEmpty) return;

      translationMap[langId] = LanguageTranslationData(
        name: fields[ApiAndParams.name]?.toString() ?? "",
        manufacturer: fields[ApiAndParams.manufacturer]?.toString() ?? "",
        description: fields[ApiAndParams.description]?.toString() ?? "",
        metaTitle: fields[ApiAndParams.meta_title]?.toString() ?? "",
        metaKeywords: fields[ApiAndParams.meta_keywords]?.toString() ?? "",
        schemaMarkup: fields[ApiAndParams.schema_markup]?.toString() ?? "",
        metaDescription: fields[ApiAndParams.meta_description]?.toString() ?? "",
        tags: fields[ApiAndParams.tags]?.toString() ?? "",
      );
    });
  }

  /// Encodes the `translations` JSON array for API save/update calls.
  ///
  /// Returns `null` when only one language is configured or there is
  /// nothing to send (avoids adding an empty `translations` param).
  String? buildTranslationsJson() {
    final allLangs = _ctx.read<LanguageProvider>().languageList?.data ?? [];
    if (allLangs.length <= 1 || translationMap.isEmpty) return null;

    // Normalise every key to the language's numeric DB id.
    // translationMap may contain both code-based keys ("en") from the API
    // load and numeric id keys ("46") from saveCurrentLanguageData —
    // de-duplicate so each language appears only once.
    final Map<String, LanguageTranslationData> normalised = {};
    for (final entry in translationMap.entries) {
      String numericId = entry.key;
      if (int.tryParse(entry.key) == null) {
        // Key is a code — resolve to numeric id via the language list.
        final lang = allLangs.firstWhere(
          (l) => l.code == entry.key || l.adminLangIdForFcm == entry.key,
          orElse: () => LanguageListData(),
        );
        final resolved = lang.adminLangIdForFcm ?? lang.id ?? "";
        if (resolved.isEmpty) continue;
        numericId = resolved;
      }
      // Numeric-keyed entries take priority (saved by the user); code-keyed
      // entries only fill in if no numeric entry exists yet.
      normalised.putIfAbsent(numericId, () => entry.value);
    }

    final translationsList = normalised.entries
        .where((entry) {
          final t = entry.value;
          return t.name.isNotEmpty ||
              t.description.isNotEmpty ||
              t.manufacturer.isNotEmpty ||
              t.metaTitle.isNotEmpty ||
              t.metaKeywords.isNotEmpty ||
              t.schemaMarkup.isNotEmpty ||
              t.metaDescription.isNotEmpty;
        })
        .map((entry) {
          final t = entry.value;
          return <String, dynamic>{
            "language_id": int.tryParse(entry.key) ?? entry.key,
            "name": t.name,
            "tags": t.tags,
            "manufacturer": t.manufacturer,
            "description": t.description,
            "meta_title": t.metaTitle,
            "meta_keywords": t.metaKeywords,
            "schema_markup": t.schemaMarkup,
            "meta_description": t.metaDescription,
          };
        })
        .toList();

    return translationsList.isEmpty ? null : jsonEncode(translationsList);
  }

  // ── Widget builders ────────────────────────────────────────────────────

  /// Builds the horizontal language-chip selector row.
  /// Returns [SizedBox.shrink] when only one language is configured.
  Widget buildLanguageChipsWidget() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, _) {
        if (languageProvider.languageState == LanguageState.loading) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                languageProvider.languageList?.data?.length ?? 0,
                (_) => CustomShimmer(
                  height: 45,
                  width: 90,
                  borderRadius: 10,
                  margin: EdgeInsetsDirectional.only(start: 10, top: 10, bottom: 10),
                ),
              ),
            ),
          );
        }

        final languages = languageProvider.languageList?.data ?? [];
        if (languages.length <= 1) return const SizedBox.shrink();

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              languages.length,
              (index) {
                final lang = languages[index];
                final isActive = lang.adminLangIdForFcm == selectedLanguageId;
                return GestureDetector(
                  onTap: () {
                    if (lang.adminLangIdForFcm == selectedLanguageId) return;
                    // 1. Persist current field values under the outgoing language.
                    saveCurrentLanguageData();
                    // 2. Restore field values for the incoming language.
                    loadLanguageData(lang.adminLangIdForFcm ?? "");
                    // 3. Switch the active chip.
                    selectedLanguageId = lang.adminLangIdForFcm ?? "";
                    _onStateChanged();
                  },
                  child: Container(
                    height: 45,
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? ColorsRes.appColor : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    margin: EdgeInsetsDirectional.only(bottom: 10, top: 10, end: 10),
                    alignment: Alignment.center,
                    child: CustomTextLabel(
                      text: lang.name ?? "",
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isActive ? ColorsRes.appColorWhite : ColorsRes.mainTextColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Builds the AI auto-translate button.
  ///
  /// [currentTagsText] should be the raw text from the tags input field.
  Widget buildAutoTranslateButton({required String currentTagsText}) {
    return Consumer<ProductTranslationProvider>(
      builder: (context, translationProvider, _) {
        return GestureDetector(
          onTap: (translationProvider.state == ProductTranslationState.loading || isTranslating)
              ? null
              : () async {
                  if (isTranslating) return;
                  isTranslating = true;
                  try {
                    if (getName().text.trim().isEmpty) {
                      showMessage(
                        context,
                        getTranslatedValue(context, productNameValidationMessageLabel),
                        MessageType.error,
                      );
                      return;
                    }

                    // Build the payload from the currently visible fields.
                    final translationData = ProductTranslationHelper.prepareTranslationData(
                      name: getName().text,
                      description: getHtmlDescription(),
                      manufacturer: getManufacturer().text,
                      metaTitle: getMetaTitle().text,
                      metaKeywords: getMetaKeywords().text,
                      schemaMarkup: getSchemaMarkup().text,
                      metaDescription: getMetaDescription().text,
                      tags: currentTagsText,
                    );

                    final langs = context.read<LanguageProvider>().languageList?.data ?? [];
                    final targetLanguage = ProductTranslationHelper.getDefaultLanguageCode(langs);

                    final success = await translationProvider.translateProduct(
                      targetLanguage: targetLanguage,
                      translationData: translationData,
                      context: context,
                    );

                    if (success) {
                      applyTranslatedData(translationProvider.translatedData);
                      loadLanguageData(selectedLanguageId);
                    }
                  } finally {
                    if (_isMounted()) {
                      isTranslating = false;
                      _onStateChanged();
                    }
                  }
                },
          child: Container(
            decoration: BoxDecoration(
              color: ColorsRes.appColor,
              borderRadius: BorderRadius.circular(5),
            ),
            padding: EdgeInsetsDirectional.only(top: 5, bottom: 5, start: 20, end: 20),
            child: translationProvider.state == ProductTranslationState.loading
                ? CustomTextLabel(
                    jsonKey: loadingLabel,
                    style: TextStyle(color: ColorsRes.appColorWhite),
                  )
                : CustomTextLabel(
                    jsonKey: autoTranslateWithAiLabel,
                    style: TextStyle(color: ColorsRes.appColorWhite),
                  ),
          ),
        );
      },
    );
  }
}
