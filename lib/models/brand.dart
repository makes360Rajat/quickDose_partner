class Brand {
  String? status;
  String? message;
  String? total;
  List<BrandData>? data;

  Brand({this.status, this.message, this.total, this.data});

  Brand.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <BrandData>[];
      json['data'].forEach((v) {
        data!.add(new BrandData.fromJson(v));
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

class BrandData {
  String? id;
  String? name;
  String? image;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? imageUrl;
  BrandsTranslations? translations;

  BrandData(
      {this.id,
      this.name,
      this.image,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.imageUrl,
      this.translations});

  BrandData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    image = json['image'].toString();
    status = json['status'].toString();
    createdAt = json['created_at'].toString();
    updatedAt = json['updated_at'].toString();
    imageUrl = json['image_url'].toString();
    translations = json['translations'] != null
        ? new BrandsTranslations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['image'] = this.image;
    data['status'] = this.status;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['image_url'] = this.imageUrl;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}
class BrandsTranslations {
  String? lang;
  String? name;

  BrandsTranslations({this.lang, this.name});

  BrandsTranslations.fromJson(Map<String, dynamic> json) {
    lang = json['lang']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final itemData = <String, dynamic>{};
    itemData['lang'] = lang;
    itemData['name'] = name;
    return itemData;
  }
}
