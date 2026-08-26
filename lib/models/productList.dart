import 'package:project/models/productDetail.dart';

class ProductList {
  String? status;
  String? message;
  String? total;
  List<ProductListItem>? data;

  ProductList({this.status, this.message, this.total, this.data});

  ProductList.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <ProductListItem>[];
      json['data'].forEach((v) {
        data!.add(new ProductListItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ProductListItem {
  String? id;
  String? name;
  String? taxId;
  String? brandId;
  String? slug;
  String? categoryId;
  String? indicator;
  String? isApproved;
  String? manufacturer;
  String? madeIn;
  String? type;
  String? isUnlimitedStock;
  String? totalAllowedQuantity;
  String? taxIncludedInPrice;
  String? fssaiLicNo;
  List<Variants>? variants;
  String? imageUrl;
  ProductTranslation? translations;

  ProductListItem(
      {this.id,
      this.name,
      this.taxId,
      this.brandId,
      this.slug,
      this.categoryId,
      this.indicator,
      this.isApproved,
      this.manufacturer,
      this.madeIn,
      this.type,
      this.isUnlimitedStock,
      this.totalAllowedQuantity,
      this.taxIncludedInPrice,
      this.fssaiLicNo,
      this.variants,
      this.imageUrl,
    this.translations,
  });

  ProductListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    taxId = json['tax_id'].toString();
    brandId = json['brand_id'].toString();
    slug = json['slug'].toString();
    categoryId = json['category_id'].toString();
    indicator = json['indicator'].toString();
    isApproved = json['is_approved'].toString();
    manufacturer = json['manufacturer'].toString();
    madeIn = json['made_in'].toString();
    type = json['type'].toString();
    isUnlimitedStock = json['is_unlimited_stock'].toString();
    totalAllowedQuantity = json['total_allowed_quantity'].toString();
    taxIncludedInPrice = json['tax_included_in_price'].toString();
    fssaiLicNo = json['fssai_lic_no'].toString();
    if (json['variants'] != null) {
      variants = <Variants>[];
      json['variants'].forEach((v) {
        variants!.add(new Variants.fromJson(v));
      });
    }
    imageUrl = json['image_url'].toString();
    translations = (json['translations'] is Map<String, dynamic>) ? ProductTranslation.fromJson(json['translations'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['tax_id'] = this.taxId;
    data['brand_id'] = this.brandId;
    data['slug'] = this.slug;
    data['category_id'] = this.categoryId;
    data['indicator'] = this.indicator;
    data['is_approved'] = this.isApproved;
    data['manufacturer'] = this.manufacturer;
    data['made_in'] = this.madeIn;
    data['type'] = this.type;
    data['is_unlimited_stock'] = this.isUnlimitedStock;
    data['total_allowed_quantity'] = this.totalAllowedQuantity;
    data['tax_included_in_price'] = this.taxIncludedInPrice;
    data['fssai_lic_no'] = this.fssaiLicNo;
    if (this.variants != null) {
      data['variants'] = this.variants!.map((v) => v.toJson()).toList();
    }
    data['image_url'] = this.imageUrl;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class Variants {
  String? id;
  String? type;
  String? status;
  String? measurement;
  String? price;
  String? discountedPrice;
  String? stock;
  String? stockUnitName;
  String? isUnlimitedStock;
  String? cartCount;
  String? taxableAmount;
  Unit? unit;

  Variants(
      {this.id,
      this.type,
      this.status,
      this.measurement,
      this.price,
      this.discountedPrice,
      this.stock,
      this.stockUnitName,
      this.isUnlimitedStock,
      this.cartCount,
      this.taxableAmount,
      this.unit});

  Variants.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    type = json['type'].toString();
    status = json['status'].toString();
    measurement = json['measurement'].toString();
    price = json['price'].toString();
    discountedPrice = json['discounted_price'].toString();
    stock = json['stock'].toString();
    stockUnitName = json['stock_unit_name'].toString();
    isUnlimitedStock = json['is_unlimited_stock'].toString();
    cartCount = json['cart_count'].toString();
    taxableAmount = json['taxable_amount'].toString();
    unit = json['unit'] != null ? new Unit.fromJson(json['unit']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['type'] = this.type;
    data['status'] = this.status;
    data['measurement'] = this.measurement;
    data['price'] = this.price;
    data['discounted_price'] = this.discountedPrice;
    data['stock'] = this.stock;
    data['stock_unit_name'] = this.stockUnitName;
    data['is_unlimited_stock'] = this.isUnlimitedStock;
    data['cart_count'] = this.cartCount;
    data['taxable_amount'] = this.taxableAmount;
    if (this.unit != null) {
      data['unit'] = this.unit!.toJson();
    }
    return data;
  }
}

class ProductTranslation {
  String? lang;
  String? languageId;
  String? name;
  String? tags;
  String? manufacturer;
  String? description;
  String? metaTitle;
  String? metaKeywords;
  String? schemaMarkup;
  String? metaDescription;
  String? languageCode;

  ProductTranslation({
    this.lang,
    this.languageId,
    this.name,
    this.tags,
    this.manufacturer,
    this.description,
    this.metaTitle,
    this.metaKeywords,
    this.schemaMarkup,
    this.metaDescription,
    this.languageCode,
  });

  ProductTranslation.fromJson(Map<String, dynamic> json) {
    lang = json['lang']?? "";
    languageId = (json['language_id']?.toString() ?? 0).toString();
    name = json['name']?.toString();
    tags = json['tags']?.toString();
    manufacturer = json['manufacturer']?.toString();
    description = json['description']?.toString();
    metaTitle = json['meta_title']?.toString();
    metaKeywords = json['meta_keywords']?.toString();
    schemaMarkup = json['schema_markup']?.toString();
    metaDescription = json['meta_description']?.toString();
    languageCode = json['language_code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lang'] = lang;
    data['language_id'] = languageId;
    data['name'] = name;
    data['tags'] = tags;
    data['manufacturer'] = manufacturer;
    data['description'] = description;
    data['meta_title'] = metaTitle;
    data['meta_keywords'] = metaKeywords;
    data['schema_markup'] = schemaMarkup;
    data['meta_description'] = metaDescription;
    data['language_code'] = languageCode;
    return data;
  }
}
