class DeliveryBoys {
  String? status;
  String? message;
  String? total;
  List<DeliveryBoysData>? data;

  DeliveryBoys({this.status, this.message, this.total, this.data});

  DeliveryBoys.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    if (json['data'] != null) {
      data = <DeliveryBoysData>[];
      json['data'].forEach((v) {
        data!.add(
          new DeliveryBoysData.fromJson(v),
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

class DeliveryBoysData {
  String? id;
  String? name;
  String? pendingOrderCount;
  DeliveryBoysTranslations? translations;

  DeliveryBoysData({this.id, this.name, this.pendingOrderCount, this.translations});

  DeliveryBoysData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    name = json['name'].toString();
    pendingOrderCount = json['pending_order_count'].toString();
    translations = json['translations'] != null
        ? DeliveryBoysTranslations.fromJson(json['translations'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['pending_order_count'] = this.pendingOrderCount;
    if (this.translations != null) {
      data['translations'] = this.translations!.toJson();
    }
    return data;
  }
}

class DeliveryBoysTranslations {
  String? lang;
  String? name;
  String? address;
  String? otherPaymentInformation;

  DeliveryBoysTranslations({this.lang, this.name, this.address, this.otherPaymentInformation});

  DeliveryBoysTranslations.fromJson(Map<String, dynamic> json) {
    lang = json['lang']??"";
    name = json['name']??"";
    address = json['address']??"";
    otherPaymentInformation = json['other_payment_information']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lang'] = this.lang;
    data['name'] = this.name;
    data['address'] = this.address;
    data['other_payment_information'] = this.otherPaymentInformation;
    return data;
  }
}
