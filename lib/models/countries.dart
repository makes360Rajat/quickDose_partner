class Countries {
  String? status;
  String? message;
  String? total;
  List<CountriesData>? data;

  Countries({this.status, this.message, this.total, this.data});

  Countries.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <CountriesData>[];
      json['data'].forEach((v) {
        data!.add(new CountriesData.fromJson(v));
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

class CountriesData {
  String? id;
  String? name;
  String? dialCode;
  String? code;
  CountryTranslation? translations;

  CountriesData({this.id, this.name, this.dialCode, this.code, this.translations});

  CountriesData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    dialCode = json['dial_code'].toString();
    code = json['code'].toString();
    translations = json['translations'] != null
        ? new CountryTranslation.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['dial_code'] = this.dialCode;
    data['code'] = this.code;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}
class CountryTranslation {
  String? lang;
  String? name;

  CountryTranslation({this.lang, this.name});

  CountryTranslation.fromJson(Map<String, dynamic> json) {
    lang = json['lang']?.toString();
    name = json['name']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lang'] = this.lang;
    data['name'] = this.name;
    return data;
  }
}
