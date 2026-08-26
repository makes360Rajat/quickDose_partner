import 'package:project/models/productList.dart';

class ProductsStockManagement {
  String? status;
  String? message;
  String? total;
  List<ProductsStockManagementData>? data;

  ProductsStockManagement({this.status, this.message, this.total, this.data});

  ProductsStockManagement.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <ProductsStockManagementData>[];
      json['data'].forEach((v) {
        data!.add(new ProductsStockManagementData.fromJson(v));
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

class ProductsStockManagementData {
  String? id;
  String? productId;
  String? name;
  String? sellerId;
  String? sellerName;
  String? status;
  String? taxId;
  String? imageUrl;
  String? indicator;
  String? manufacturer;
  String? madeIn;
  String? productVariantId;
  String? type;
  String? price;
  String? discountedPrice;
  String? measurement;
  String? pvStatus;
  String? stock;
  String? stockUnitId;
  String? shortCode;
  String? stockUnit;
  ProductTranslation? translations;
  UnitTranslation? unitTranslations;

  ProductsStockManagementData(
      {this.id,
      this.productId,
      this.name,
      this.sellerId,
      this.sellerName,
      this.status,
      this.taxId,
      this.imageUrl,
      this.indicator,
      this.manufacturer,
      this.madeIn,
      this.productVariantId,
      this.type,
      this.price,
      this.discountedPrice,
      this.measurement,
      this.pvStatus,
      this.stock,
      this.stockUnitId,
      this.shortCode,
      this.stockUnit,
      this.translations,
      this.unitTranslations,
  });

  ProductsStockManagementData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    productId = json['product_id'].toString();
    name = json['name'].toString();
    sellerId = json['seller_id'].toString();
    sellerName = json['seller_name'].toString();
    status = json['status'].toString();
    taxId = json['tax_id'].toString();
    imageUrl = json['image_url'].toString();
    indicator = json['indicator'].toString();
    manufacturer = json['manufacturer'].toString();
    madeIn = json['made_in'].toString();
    productVariantId = json['product_variant_id'].toString();
    type = json['type'].toString();
    price = json['price'].toString();
    discountedPrice = json['discounted_price'].toString();
    measurement = json['measurement'].toString();
    pvStatus = json['pv_status'].toString();
    stock = json['stock'].toString();
    stockUnitId = json['stock_unit_id'].toString();
    shortCode = json['short_code'].toString();
    stockUnit = json['stock_unit'].toString();
    translations = (json['translations'] is Map<String, dynamic>) ? ProductTranslation.fromJson(json['translations'] as Map<String, dynamic>) : null;
    unitTranslations = (json['unit_translations'] is Map<String, dynamic>) ? UnitTranslation.fromJson(json['unit_translations'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['product_id'] = this.productId;
    data['name'] = this.name;
    data['seller_id'] = this.sellerId;
    data['seller_name'] = this.sellerName;
    data['status'] = this.status;
    data['tax_id'] = this.taxId;
    data['image_url'] = this.imageUrl;
    data['indicator'] = this.indicator;
    data['manufacturer'] = this.manufacturer;
    data['made_in'] = this.madeIn;
    data['product_variant_id'] = this.productVariantId;
    data['type'] = this.type;
    data['price'] = this.price;
    data['discounted_price'] = this.discountedPrice;
    data['measurement'] = this.measurement;
    data['pv_status'] = this.pvStatus;
    data['stock'] = this.stock;
    data['stock_unit_id'] = this.stockUnitId;
    data['short_code'] = this.shortCode;
    data['stock_unit'] = this.stockUnit;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    if (this.unitTranslations != null) {
      data['unit_translations'] = this.unitTranslations!.toJson();
    }
    return data;
  }
}
class UnitTranslation {
  String? id;
  String? unitId;
  String? languageId;
  String? name;
  String? shortCode;
  String? updatedAt;

  UnitTranslation({this.id, this.unitId, this.languageId, this.name, this.shortCode, this.updatedAt});

  UnitTranslation.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    unitId = json['unit_id']?.toString();
    languageId = json['language_id']?.toString();
    name = json['name']?.toString();
    shortCode = json['short_code']?.toString();
    updatedAt = json['updated_at']?.toString();
    name = json['name']?.toString();
    shortCode = json['short_code']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['unit_id'] = this.unitId;
    data['language_id'] = this.languageId;
    data['name'] = this.name;
    data['short_code'] = this.shortCode;
    return data;
  }
}