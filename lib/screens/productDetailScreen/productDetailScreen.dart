import 'package:flutter/material.dart';
import 'package:project/models/productList.dart';
import 'package:project/provider/productDeleteProvider.dart';
import 'package:project/provider/productDetailViewProvider.dart';
import 'package:project/screens/productDetailScreen/widget/productDetailsTab.dart';
import 'package:project/screens/productDetailScreen/widget/productReviewsTab.dart';

import '../../helper/utils/generalImports.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductListItem product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    Future.delayed(Duration.zero, () => callApi());
  }

  Future<void> callApi() async {
    await context.read<ProductDetailViewProvider>().fetchProductDetail(productId: widget.product.id ?? '', context: context);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: ColorsRes.mainTextColor),
          onPressed: () => Navigator.pop(context, _hasChanges ? true : null),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsetsDirectional.all(8),
            margin: EdgeInsetsDirectional.only(top: 16, start: 16, end: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(color: ColorsRes.appColor, borderRadius: BorderRadius.circular(8)),
              indicatorSize: TabBarIndicatorSize.tab,
              isScrollable: false,
              dividerColor: ColorsRes.appColorTransparent,
              labelColor: ColorsRes.appColorWhite,
              unselectedLabelColor: ColorsRes.mainTextColor,
              labelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              tabs: [
                Tab(text: getTranslatedValue(context, productDetailsLabel)),
                Tab(text: getTranslatedValue(context, reviewsLabel)),
              ],
            ),
          ),
          Expanded(
            child: Consumer<ProductDetailViewProvider>(
              builder: (context, provider, _) {
                if (provider.state == ProductDetailViewState.loading || provider.state == ProductDetailViewState.initial) {
                  return Center(child: CircularProgressIndicator(color: ColorsRes.appColor));
                }
                if (provider.state == ProductDetailViewState.error) {
                  return Center(
                    child: DefaultBlankItemMessageScreen(
                      image: "no_order_icon",
                      title: somethingWentWrongMessageTitleLabel,
                      description: somethingWentWrongMessageDescriptionLabel,
                      buttonTitle: tryAgainLabel,
                      callback: callApi,
                    ),
                  );
                }
                final detail = provider.productDetailData;
                return TabBarView(
                  controller: _tabController,
                  children: [
                    ProductDetailsTab(product: detail),
                    ProductReviewsTab(productId: widget.product.id ?? ''),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: ColorsRes.appColorBlack.withValues(alpha: 0.08), offset: Offset(0, -4), blurRadius: 32, spreadRadius: 0)],
      ),
      child: Row(
        children: [
          _buildBottomSvgBtn(AppAssets.deleteIcon, Theme.of(context).scaffoldBackgroundColor, ColorsRes.mainTextColor, () {
            if (widget.product.variants!.length <= 1) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: CustomTextLabel(jsonKey: deleteProductLabel),
                    backgroundColor: Theme.of(context).cardColor,
                    surfaceTintColor: ColorsRes.appColorTransparent,
                    content: CustomTextLabel(
                      jsonKey: areYouSureYouWantToDeleteProductVariantLabel,
                      style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 15),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: CustomTextLabel(
                          jsonKey: cancelLabel,
                          softWrap: true,
                          style: TextStyle(color: ColorsRes.subTitleTextColor, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      getSizedBox(width: 10),
                      ChangeNotifierProvider(
                        create: (context) => DeleteProductProvider(),
                        child: Consumer<DeleteProductProvider>(
                          builder: (context, deleteProductProvider, child) {
                            return GestureDetector(
                              onTap: () async {
                                await deleteProductProvider
                                    .deleteProducts(
                                      params: {"id": widget.product.variants?[0].id.toString() ?? ""},
                                      context: context,
                                      from: "product_listing",
                                    )
                                    .then((value) {
                                      if (value != null) {
                                        _hasChanges = true;
                                        Navigator.pop(context);
                                        Navigator.pop(context, _hasChanges ? true : null);
                                      }
                                    });
                              },
                              child: deleteProductProvider.sellerProductDeleteState == SellerDeleteProductState.loading
                                  ? Container(height: 24, width: 24, child: CircularProgressIndicator(color: ColorsRes.appColor))
                                  : CustomTextLabel(
                                      jsonKey: okLabel,
                                      style: TextStyle(color: ColorsRes.appColor, fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              );
            } else {
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: DesignConfig.setRoundedBorderSpecific(20, istop: true),
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
                    child: Wrap(
                      children: [
                        Padding(
                          padding: EdgeInsetsDirectional.only(start: 15, end: 15),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: Constant.borderRadius10,
                                clipBehavior: Clip.antiAliasWithSaveLayer,
                                child: setNetworkImg(boxFit: BoxFit.fill, image: widget.product.imageUrl.toString(), height: 70, width: 70),
                              ),
                              getSizedBox(width: 10),
                              Expanded(
                                child: CustomTextLabel(
                                  text: widget.product.translations?.name ?? "",
                                  softWrap: true,
                                  style: TextStyle(fontSize: 20, color: ColorsRes.mainTextColor),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsetsDirectional.all(Constant.paddingOrMargin15),
                          child: ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: widget.product.variants?.length ?? 0,
                            itemBuilder: (BuildContext context, int index) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.clip,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                style: TextStyle(fontSize: 15, color: ColorsRes.mainTextColor, decorationThickness: 2),
                                                text: "${widget.product.variants?[index].measurement} ",
                                              ),
                                              WidgetSpan(
                                                child: CustomTextLabel(
                                                  text: widget.product.variants?[index].unit?.shortCode ?? "",
                                                  softWrap: true,
                                                  style: TextStyle(fontSize: 14, color: ColorsRes.mainTextColor),
                                                ),
                                              ),
                                              TextSpan(
                                                text: double.parse(widget.product.variants?[index].discountedPrice.toString() ?? "0.0") != 0
                                                    ? " | "
                                                    : "",
                                                style: TextStyle(color: ColorsRes.mainTextColor),
                                              ),
                                              TextSpan(
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: ColorsRes.mainTextColor,
                                                  decoration: TextDecoration.lineThrough,
                                                  decorationThickness: 2,
                                                ),
                                                text: double.parse(widget.product.variants?[index].discountedPrice.toString() ?? "0.0") != 0
                                                    ? widget.product.variants![index].price ?? "0.0"
                                                    : "0.0",
                                              ),
                                            ],
                                          ),
                                        ),
                                        CustomTextLabel(
                                          text: double.parse(widget.product.variants![index].discountedPrice.toString()) != 0
                                              ? widget.product.variants![index].discountedPrice.toString().currency
                                              : widget.product.variants![index].price.toString().currency,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 17, color: ColorsRes.appColor, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextLabel(
                                      text:
                                          "${getTranslatedValue(context, stockLabel)} : ${widget.product.variants![index].isUnlimitedStock == "1" ? getTranslatedValue(context, unlimitedLabel) : widget.product.variants![index].stock}${widget.product.variants![index].isUnlimitedStock == "1" ? "" : " ${widget.product.variants![index].unit?.shortCode ?? ""}"}",
                                      style: TextStyle(fontSize: 12, color: ColorsRes.mainTextColor),
                                    ),
                                  ),
                                  getSizedBox(width: 10),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: CustomTextLabel(jsonKey: deleteProductLabel),
                                            backgroundColor: Theme.of(context).cardColor,
                                            surfaceTintColor: Colors.transparent,
                                            content: CustomTextLabel(
                                              jsonKey: areYouSureYouWantToDeleteProductVariantLabel,
                                              style: TextStyle(color: ColorsRes.mainTextColor, fontSize: 15),
                                            ),
                                            actions: [
                                              GestureDetector(
                                                onTap: () => Navigator.pop(context),
                                                child: CustomTextLabel(
                                                  jsonKey: cancelLabel,
                                                  softWrap: true,
                                                  style: TextStyle(color: ColorsRes.subTitleTextColor, fontSize: 15, fontWeight: FontWeight.bold),
                                                ),
                                              ),
                                              getSizedBox(width: 10),
                                              ChangeNotifierProvider(
                                                create: (context) => DeleteProductProvider(),
                                                child: Consumer<DeleteProductProvider>(
                                                  builder: (context, deleteProductProvider, child) {
                                                    return GestureDetector(
                                                      onTap: () async {
                                                        await deleteProductProvider
                                                            .deleteProducts(
                                                              params: {"id": widget.product.variants![index].id.toString()},
                                                              context: context,
                                                              from: "product_listing",
                                                            )
                                                            .then((value) {
                                                              if (value != null) {
                                                                _hasChanges = true;
                                                                Navigator.pop(context);
                                                                Navigator.pop(context);
                                                                callApi();
                                                              }
                                                            });
                                                      },
                                                      child: deleteProductProvider.sellerProductDeleteState == SellerDeleteProductState.loading
                                                          ? Container(
                                                              height: 24,
                                                              width: 24,
                                                              child: CircularProgressIndicator(color: ColorsRes.appColor),
                                                            )
                                                          : CustomTextLabel(
                                                              jsonKey: okLabel,
                                                              style: TextStyle(color: ColorsRes.appColor, fontSize: 15, fontWeight: FontWeight.bold),
                                                            ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Container(
                                      alignment: AlignmentDirectional.center,
                                      height: 24,
                                      width: 24,
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: BoxDecoration(color: ColorsRes.appColorRed, borderRadius: BorderRadius.circular(5)),
                                      child: Icon(Icons.delete_forever_rounded, color: ColorsRes.appColorWhite, size: 17),
                                    ),
                                  ),
                                ],
                              );
                            },
                            separatorBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                child: Divider(color: ColorsRes.grey, height: 5),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          }),
          const SizedBox(width: 16),
          _buildBottomSvgBtn(AppAssets.cloneIcon, ColorsRes.appColor.withValues(alpha: 0.2), ColorsRes.appColor, () {
            Navigator.pushNamed(context, productAddUpdateScreen, arguments: [widget.product.id.toString(), "duplicate"]).then((value) {
              if (value != null) {
                _hasChanges = true;
                callApi();
              }
            });
          }),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, productAddUpdateScreen, arguments: [widget.product.id.toString(), "update"]).then((value) {
                  if (value != null) {
                    _hasChanges = true;
                    callApi();
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsRes.appColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextLabel(
                    jsonKey: editLabel,
                    style: TextStyle(
                      color: ColorsRes.appColorWhite,
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                    ),
                  ),
                  getSizedBox(width: 12),
                  defaultImg(image: AppAssets.editProductIcon, height: 16, width: 16, iconColor: ColorsRes.appColorWhite),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSvgBtn(String svgAsset, Color bg, Color iconColor, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsetsDirectional.all(16),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: defaultImg(image: svgAsset, height: 24, width: 24, iconColor: iconColor),
      ),
    );
  }
}
