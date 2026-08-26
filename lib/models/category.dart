class Category {
  String? status;
  String? message;
  String? total;
  List<CategoryData>? data;

  Category({this.status, this.message, this.total, this.data});

  Category.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <CategoryData>[];
      json['data'].forEach((v) {
        data!.add(
          new CategoryData.fromJson(v),
        );
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this
          .data!
          .map(
            (v) => v.toJson(),
          )
          .toList();
    }
    return data;
  }
}

class CategoryData {
  String? id;
  String? name;
  String? parentId;
  String? imageUrl;
  bool? hasChild;
  CategoryTranslations? translations;

  CategoryData(
      {this.id, this.name, this.parentId, this.imageUrl, this.hasChild, this.translations});

  CategoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    parentId = json['parent_id'].toString();
    imageUrl = json['image_url'].toString();
    hasChild = json['has_child'] ?? false;
    translations = json['translations'] != null ? new CategoryTranslations.fromJson(json['translations']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['parent_id'] = this.parentId;
    data['image_url'] = this.imageUrl;
    data['has_child'] = this.hasChild;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class CategoryTranslations {
  String? lang;
  String? name;
  String? subtitle;
  String? metaTitle;
  String? metaKeywords;
  String? schemaMarkup;
  String? metaDescription;

  CategoryTranslations({this.lang, this.name, this.subtitle, this.metaTitle, this.metaKeywords, this.schemaMarkup, this.metaDescription});

  CategoryTranslations.fromJson(Map<String, dynamic> json) {
    lang = json['lang'];
    name = json['name'];
    subtitle = json['subtitle'];
    metaTitle = json['meta_title'];
    metaKeywords = json['meta_keywords'];
    schemaMarkup = json['schema_markup'];
    metaDescription = json['meta_description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lang'] = this.lang;
    data['name'] = this.name;
    data['subtitle'] = this.subtitle;
    data['meta_title'] = this.metaTitle;
    data['meta_keywords'] = this.metaKeywords;
    data['schema_markup'] = this.schemaMarkup;
    data['meta_description'] = this.metaDescription;
    return data;
  }
}
