import 'dart:convert';
import 'package:project/helper/utils/constant.dart';

class DeliveryBoyOrder {
  DeliveryBoyOrder({
    this.status,
    this.message,
    this.total,
    this.data,
  });

  late final String? status;
  late final String? message;
  late final String? total;
  late final DeliveryBoyOrderData? data;

  DeliveryBoyOrder.fromJson(Map<String, dynamic> json) {
    status = json['status'].toString();
    message = json['message'].toString();
    total = json['total'].toString();
    data = DeliveryBoyOrderData.fromJson(json['data']);
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['status'] = status;
    _data['message'] = message;
    _data['total'] = total;
    _data['data'] = data?.toJson();
    return _data;
  }
}

class DeliveryBoyOrderData {
  DeliveryBoyOrderData({
    this.orders,
  });

  late final List<DeliveryBoyOrdersListItem>? orders;

  DeliveryBoyOrderData.fromJson(Map<String, dynamic> json) {
    orders = List.from(json['orders'])
        .map(
          (e) => DeliveryBoyOrdersListItem.fromJson(e),
        )
        .toList();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['orders'] = orders
        ?.map(
          (e) => e.toJson(),
        )
        .toList();
    return _data;
  }
}

class StatusOrderCount {
  StatusOrderCount({
    this.id,
    this.status,
    this.orderCount,
    this.statusName,
  });

  late final String? id;
  late final String? status;
  late final String? orderCount;
  late final String? statusName;

  StatusOrderCount.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    status = json['status'].toString();
    orderCount = json['order_count'].toString();
    statusName = json['status_name'].toString();
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['status'] = status;
    _data['order_count'] = orderCount;
    _data['status_name'] = statusName;
    return _data;
  }
}

class DeliveryBoyOrdersListItem {
  DeliveryBoyOrdersListItem({
    this.id,
    this.deliveryBoyId,
    this.orderId,
    this.mobile,
    this.orderNote,
    this.total,
    this.deliveryCharge,
    this.taxAmount,
    this.taxPercentage,
    this.discount,
    this.finalTotal,
    this.paymentMethod,
    this.address,
    this.latitude,
    this.longitude,
    this.deliveryTime,
    this.activeStatus,
    this.pincodeId,
    this.otp,
    this.addressId,
    this.createdAt,
    this.deliveryBoyName,
    this.userName,
    this.userMobile,
    this.orderStatus,
    this.orderStatusName,
    this.deliveryProofImages,
  });

  late final String? id;
  late final String? deliveryBoyId;
  late final String? orderId;
  late final String? mobile;
  late final String? orderNote;
  late final String? total;
  late final String? deliveryCharge;
  late final String? taxAmount;
  late final String? taxPercentage;
  late final String? discount;
  late final String? finalTotal;
  late final String? paymentMethod;
  late final String? address;
  late final String? latitude;
  late final String? longitude;
  late final String? deliveryTime;
  late final String? activeStatus;
  late final String? pincodeId;
  late final String? otp;
  late final String? addressId;
  late final String? createdAt;
  late final String? deliveryBoyName;
  late final String? userName;
  late final String? userMobile;
  late final String? orderStatus;
  late final String? orderStatusName;
  late final List<String>? deliveryProofImages;

  DeliveryBoyOrdersListItem.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    deliveryBoyId = json['delivery_boy_id'].toString();
    orderId = json['order_id'].toString();
    mobile = json['mobile'].toString();
    orderNote = json['order_note']??"";
    total = json['total'].toString();
    deliveryCharge = json['delivery_charge'].toString();
    taxAmount = json['tax_amount'].toString();
    taxPercentage = json['tax_percentage'].toString();
    discount = json['discount'].toString();
    finalTotal = json['final_total'].toString();
    paymentMethod = json['payment_method'].toString();
    address = json['address'].toString();
    latitude = json['latitude'].toString();
    longitude = json['longitude'].toString();
    deliveryTime = json['delivery_time'].toString();
    activeStatus = json['active_status'].toString();
    addressId = json['address_id'].toString();
    createdAt = json['created_at'].toString();
    deliveryBoyName = json['delivery_boy_name'].toString();
    userName = json['user_name'].toString();
    userMobile = json['user_mobile'].toString();
    orderStatus = json['order_status'].toString();
    otp = json['otp'].toString();
    pincodeId = json['pincode_id'].toString();
    orderStatusName = json['order_status_name'].toString();

    dynamic rawDeliveryImgs = json['delivery_proof_images'] ?? json['delivery_images'];
    if (rawDeliveryImgs != null) {
      if (rawDeliveryImgs is String && rawDeliveryImgs.trim().isNotEmpty) {
        try {
          rawDeliveryImgs = jsonDecode(rawDeliveryImgs);
        } catch (_) {
          if (rawDeliveryImgs.contains(',')) {
            rawDeliveryImgs = rawDeliveryImgs.split(',').map((e) => e.trim()).toList();
          } else {
            rawDeliveryImgs = [rawDeliveryImgs];
          }
        }
      }
      if (rawDeliveryImgs is String && rawDeliveryImgs.trim().isNotEmpty) {
        try {
          rawDeliveryImgs = jsonDecode(rawDeliveryImgs);
        } catch (_) {}
      }
      if (rawDeliveryImgs is List) {
        deliveryProofImages = rawDeliveryImgs.map((x) {
          String url = x.toString().trim();
          if (url.isEmpty || url == "null") return '';
          if (url.startsWith('http://') || url.startsWith('https://')) {
            return url;
          }
          String cleanPath = url.startsWith('/') ? url.substring(1) : url;
          if (cleanPath.startsWith('storage/')) {
            return "${Constant.hostUrl}$cleanPath";
          }
          return "${Constant.hostUrl}storage/$cleanPath";
        }).where((url) => url.isNotEmpty).toList();
      } else {
        deliveryProofImages = [];
      }
    } else {
      deliveryProofImages = [];
    }
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['delivery_boy_id'] = deliveryBoyId;
    _data['order_id'] = orderId;
    _data['mobile'] = mobile;
    _data['order_note'] = orderNote;
    _data['total'] = total;
    _data['delivery_charge'] = deliveryCharge;
    _data['tax_amount'] = taxAmount;
    _data['tax_percentage'] = taxPercentage;
    _data['discount'] = discount;
    _data['final_total'] = finalTotal;
    _data['payment_method'] = paymentMethod;
    _data['address'] = address;
    _data['latitude'] = latitude;
    _data['longitude'] = longitude;
    _data['delivery_time'] = deliveryTime;
    _data['active_status'] = activeStatus;
    _data['pincode_id'] = pincodeId;
    _data['otp'] = otp;
    _data['address_id'] = addressId;
    _data['created_at'] = createdAt;
    _data['delivery_boy_name'] = deliveryBoyName;
    _data['user_name'] = userName;
    _data['user_mobile'] = userMobile;
    _data['order_status'] = orderStatus;
    _data['order_status_name'] = orderStatusName;
    _data['delivery_proof_images'] = deliveryProofImages;
    return _data;
  }
}
