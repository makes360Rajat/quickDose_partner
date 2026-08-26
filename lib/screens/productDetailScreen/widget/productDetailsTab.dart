import 'package:flutter/material.dart';
import 'package:project/helper/utils/generalImports.dart';
import 'package:project/models/productDetail.dart';
import 'package:project/models/productList.dart';
import 'package:flutter_html/flutter_html.dart';

class ProductDetailsTab extends StatefulWidget {
  final ProductDetailData? product;

  const ProductDetailsTab({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailsTab> createState() => _ProductDetailsTabState();
}

class _ProductDetailsTabState extends State<ProductDetailsTab> {
  bool _showAllVariants = false;
  bool _specsExpanded = true;
  bool _overviewExpanded = true;
  /// Returns the [ProductTranslation] for the currently selected app language.
  /// Falls back to the first non-empty translation, then to null.
  ProductTranslation? _getProductTranslation(ProductDetailData product) {
    final translations = product.translations;
    if (translations == null || translations.isEmpty) return null;

    final langCode = Constant.session.getData(SessionManager.keySelectedLanguageCode);

    // Try exact language code match first
    final match = translations[langCode];
    if (match != null && (match.name?.isNotEmpty ?? false)) return match;

    // Fall back to the first entry that has a non-empty name
    return translations.values.firstWhere((t) => t.name?.isNotEmpty ?? false, orElse: () => translations.values.first);
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    if (product == null) return const SizedBox.shrink();

    final variants = product.variants ?? [];
    final visibleVariants = _showAllVariants ? variants : variants.take(3).toList();
    final translation = _getProductTranslation(product);

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductCard(context, product, translation),
          getSizedBox(height: 12),
          if (variants.length > 1) ...[_buildVariantsSection(context, variants, visibleVariants), getSizedBox(height: 12)],
          _buildIndicatorRow(context, product),
          getSizedBox(height: 12),
          _buildSpecificationsSection(context, product, translation),
          getSizedBox(height: 12),
          _buildOverviewSection(context, product, translation),
          getSizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductDetailData product, ProductTranslation? translation) {
    final firstVariant = product.variants?.isNotEmpty == true ? product.variants!.first : null;
    final isOutOfStock = (firstVariant?.status.toString() == "0" || firstVariant?.isUnlimitedStock == "0" && firstVariant?.stock.toString() == "0");

    return Container(
      padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: Constant.borderRadius10,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: setNetworkImg(boxFit: BoxFit.cover, image: product.imageUrl ?? '', height: 80, width: 80),
          ),
          getSizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomTextLabel(
                  text: translation?.name?.isNotEmpty == true ? translation!.name! : product.name ?? '',
                  softWrap: true,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsRes.mainTextColor),
                ),
                getSizedBox(height: 4),
                if (firstVariant != null)
                  Row(
                    children: [
                      CustomTextLabel(
                        text: '${firstVariant.measurement ?? ''} - ${firstVariant.unit?.translation?.shortCode ?? ''}',
                        style: TextStyle(fontSize: 13, color: ColorsRes.subTitleTextColor),
                      ),
                      getSizedBox(width: 8),
                      Container(width: 1, height: 12, color: ColorsRes.subTitleTextColor),
                      getSizedBox(width: 8),
                      /* CustomTextLabel(
                        text: '${firstVariant.isUnlimitedStock == "1" ? getTranslatedValue(context, unlimitedLabel) : firstVariant.stock}${firstVariant.isUnlimitedStock == "1" ? "" : " ${firstVariant.unit?.translation?.shortCode ?? ""}"} - ${getTranslatedValue(context, stockLabel)}',
                        style: TextStyle(fontSize: 13, color: ColorsRes.subTitleTextColor),
                      ), */isOutOfStock
                  ? CustomTextLabel(
                      text: getTranslatedValue(context, outOfStockLabel),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsRes.appColorRed),
                    )
                  : CustomTextLabel(
                      text: '${firstVariant.isUnlimitedStock == "1" ? getTranslatedValue(context, unlimitedLabel) : firstVariant.stock}${firstVariant.isUnlimitedStock == "1" ? "" : " ${firstVariant.unit?.translation?.shortCode ?? ""}"} - ${getTranslatedValue(context, stockLabel)}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsRes.subTitleTextColor),
                    ),
                    ],
                  ),
                getSizedBox(height: 6),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "${_effectivePrice(firstVariant).currency} ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsRes.appColor),
                      ),
                      if (_hasDiscount(firstVariant))
                        TextSpan(
                          text: '${(firstVariant!.price ?? '0').currency}',
                          style: TextStyle(
                            fontSize: 13,
                            color: ColorsRes.subTitleTextColor,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: ColorsRes.subTitleTextColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _effectivePrice(ProductDetailVariants? v) {
    if (v == null) return '0';
    final disc = double.tryParse(v.discountedPrice ?? '0') ?? 0;
    return disc != 0 ? v.discountedPrice ?? '0' : v.price ?? '0';
  }

  bool _hasDiscount(ProductDetailVariants? v) {
    if (v == null) return false;
    final disc = double.tryParse(v.discountedPrice ?? '0') ?? 0;
    return disc != 0 && v.price != v.discountedPrice;
  }

  Widget _buildVariantsSection(BuildContext context, List<ProductDetailVariants> all, List<ProductDetailVariants> visible) {
    return Container(
      padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextLabel(
            text: getTranslatedValue(context, otherVariantsLabel),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: ColorsRes.mainTextColor),
          ),
          getSizedBox(height: 10),
          ...visible.skip(1).map((v) {
            final index = visible.indexOf(v);
            return Column(
              children: [
                if (index > 1) Divider(height: 1, color: ColorsRes.grey, thickness: 0),
                _buildVariantRow(context, v),
              ],
            );
          }).toList(),
          if (all.length > 4)
            GestureDetector(
              onTap: () => setState(() => _showAllVariants = !_showAllVariants),
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextLabel(
                      text: getTranslatedValue(context, _showAllVariants ? viewLessLabel : viewMoreLabel),
                      style: TextStyle(fontSize: 13, color: ColorsRes.mainTextColor, fontWeight: FontWeight.w500),
                    ),
                    getSizedBox(width: 4),
                    Icon(_showAllVariants ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, size: 18, color: ColorsRes.mainTextColor),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVariantRow(BuildContext context, ProductDetailVariants v) {
    // final isOutOfStock = v.stock == '0' && v.stock != null;
    final isOutOfStock = (v.status.toString() == "0" || v.isUnlimitedStock == "0" && v.stock.toString() == "0");
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 6),
      child: Row(
        children: [
          Column(crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${v.measurement ?? ''}  ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsRes.mainTextColor),
                    ),
                    TextSpan(
                      text: v.unit?.translation?.shortCode ?? '',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: ColorsRes.subTitleTextColor),
                    ),
                  ],
                ),
              ),
              getSizedBox(height: 5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${_effectivePrice(v).currency}  ',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColorsRes.appColor),
                    ),
                    if (_hasDiscount(v))
                      TextSpan(
                        text: (v.price ?? '0').currency,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: ColorsRes.subTitleTextColor,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: ColorsRes.subTitleTextColor,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: .end,
            children: [
              CustomTextLabel(
                text: getTranslatedValue(context, stockLabel),
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsRes.subTitleTextColor),
              ),
              getSizedBox(height: 5),
              isOutOfStock
                  ? CustomTextLabel(
                      text: getTranslatedValue(context, outOfStockLabel),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ColorsRes.appColorRed),
                    )
                  : CustomTextLabel(
                      text: '${v.isUnlimitedStock == "1" ? getTranslatedValue(context, unlimitedLabel) : v.stock}${v.isUnlimitedStock == "1" ? "" : " ${v.unit?.translation?.shortCode ?? ""}"}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ColorsRes.mainTextColor),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow(BuildContext context, ProductDetailData product) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(vertical: 14),
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (product.indicator == '1' || product.indicator == '2')
            _buildIndicatorItem(
              context,
              product.indicator == '2' ? AppAssets.nonVegIndicatorIcon : AppAssets.vegIndicatorIcon,
              product.indicator == '2' ? getTranslatedValue(context, nonVegetarianLabel) : getTranslatedValue(context, vegetarianLabel),
            ),
          _buildIndicatorItem(
            context,
            AppAssets.cancelableIcon,
            product.cancelableStatus == '1' ? getTranslatedValue(context, cancelableLabel) : getTranslatedValue(context, notCancelableLabel),
          ),
          _buildIndicatorItem(
            context,
            AppAssets.returnableIcon,
            product.returnStatus == '1' ? getTranslatedValue(context, returnableLabel) : getTranslatedValue(context, notReturnableLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(BuildContext context, String svgAsset, String label) {
    return Column(
      children: [
        defaultImg(image: svgAsset, height: 30, width: 52.58),
        getSizedBox(height: 10),
        CustomTextLabel(
          text: label,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: ColorsRes.mainTextColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSpecificationsSection(BuildContext context, ProductDetailData product, ProductTranslation? translation) {
    final specs = <_SpecItem>[
      _SpecItem(getTranslatedValue(context, productCategoryLabel), product.category?.translations?.name ?? '-'),
      _SpecItem(getTranslatedValue(context, fssaiNoTitleLabel), product.fssaiLicNo ?? '-'),
      _SpecItem(getTranslatedValue(context, packTypeLabel), product.type ?? '-'),
      _SpecItem(
        getTranslatedValue(context, statusLabel),
        product.isApproved == '1' ? getTranslatedValue(context, approvedLabel) : getTranslatedValue(context, notApprovedLabel),
      ),
      _SpecItem(getTranslatedValue(context, productBrandLabel), product.brand?.translations?.name ?? '-'),
      _SpecItem(getTranslatedValue(context, madeInTitleLabel), product.madeInCountry?.translations?.name ?? '-'),
      _SpecItem(getTranslatedValue(context, manufacturerTitleLabel), (translation?.manufacturer?.trim().isNotEmpty == true ? translation!.manufacturer! : product.manufacturer?.trim().isNotEmpty == true ? product.manufacturer! : '-'),),
      _SpecItem(getTranslatedValue(context, sellerNameLabel), product.seller?.translations?.name ?? '-'),
    ];

    return _buildCollapsibleSection(
      context: context,
      title: getTranslatedValue(context, productSpecificationsLabel),
      expanded: _specsExpanded,
      onToggle: () => setState(() => _specsExpanded = !_specsExpanded),
      child: Column(
        children: specs
            .map(
              (s) => Padding(
                padding: EdgeInsetsDirectional.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 110,
                      child: CustomTextLabel(
                        text: s.label,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ColorsRes.mainTextColor),
                      ),
                    ),
                    CustomTextLabel(
                      text: ' : ',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ColorsRes.mainTextColor),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 16.0),
                        child: CustomTextLabel(
                          text: s.value,
                          softWrap: true,
                          style: TextStyle(fontSize: 14, color: ColorsRes.mainTextColor, fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, ProductDetailData product, ProductTranslation? translation) {
    final description = (translation?.description?.isNotEmpty == true ? translation!.description! : product.description) ?? '';
    return _buildCollapsibleSection(
      context: context,
      title: getTranslatedValue(context, productOverviewLabel),
      expanded: _overviewExpanded,
      onToggle: () => setState(() => _overviewExpanded = !_overviewExpanded),
      child: description.isNotEmpty
          ? Html(
              data: description,
              /* style: {
                'body': Style(
                  fontSize: FontSize(13),
                  color: ColorsRes.mainTextColor,
                  lineHeight: LineHeight(1.6),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              }, */
            )
          : CustomTextLabel(
              text: getTranslatedValue(context, noDescriptionLabel),
              softWrap: true,
              style: TextStyle(fontSize: 13, color: ColorsRes.subTitleTextColor, height: 1.6),
            ),
    );
  }

  Widget _buildCollapsibleSection({
    required BuildContext context,
    required String title,
    required bool expanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsetsDirectional.all(16),
      decoration: DesignConfig.boxDecoration(Theme.of(context).cardColor, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextLabel(
                  text: title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: ColorsRes.mainTextColor),
                ),
                Icon(expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: ColorsRes.subTitleTextColor),
              ],
            ),
          ),
          if (expanded) ...[getSizedBox(height: 10), child],
        ],
      ),
    );
  }
}

class _SpecItem {
  final String label;
  final String value;
  _SpecItem(this.label, this.value);
}
