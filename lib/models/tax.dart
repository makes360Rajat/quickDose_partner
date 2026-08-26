class Tax {
  String? status;
  String? message;
  String? total;
  List<TaxesData>? data;

  Tax({this.status, this.message, this.total, this.data});

  Tax.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <TaxesData>[];
      json['data'].forEach((v) {
        data!.add(new TaxesData.fromJson(v));
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

class TaxesData {
  String? id;
  String? title;
  String? percentage;
  String? status;
  TaxTranslationsModel? translations;

  TaxesData({this.id, this.title, this.percentage, this.status, this.translations});

  TaxesData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'].toString();
    percentage = json['percentage'].toString();
    status = json['status'].toString();
    translations = json['translations'] != null
        ? new TaxTranslationsModel.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['title'] = this.title;
    data['percentage'] = this.percentage;
    data['status'] = this.status;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class TaxTranslationsModel {
  String? id;
  String? taxId;
  String? languageId;
  String? title;
  String? createdAt;
  String? updatedAt;

  TaxTranslationsModel({this.id, this.taxId, this.languageId, this.title, this.createdAt, this.updatedAt});

  TaxTranslationsModel.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    taxId = (json['tax_id']??0).toString();
    languageId = (json['language_id']??0).toString();
    title = json['title']??"";
    createdAt = json['created_at']??"";
    updatedAt = json['updated_at']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['tax_id'] = taxId;
    data['language_id'] = languageId;
    data['title'] = title;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
