class ReturnOrderDetail {
  String? status;
  String? message;
  String? total;
  ReturnOrderDetailData? data;

  ReturnOrderDetail({this.status, this.message, this.total, this.data});

  ReturnOrderDetail.fromJson(Map<String, dynamic> json) {
    status = (json['status']??0).toString();
    message = json['message']??"";
    total = (json['total']??0).toString();
    data = json['data'] != null ? new ReturnOrderDetailData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['message'] = this.message;
    data['total'] = this.total;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class ReturnOrderDetailData {
  String? id;
  String? userId;
  String? productVariantId;
  String? orderId;
  String? orderItemId;
  String? reason;
  String? status;
  String? remarks;
  String? deliveryBoyId;
  String? cancellationReason;
  String? createdAt;
  String? updatedAt;
  String? customerName;
  String? customerMobile;
  String? quantity;
  String? price;
  String? subTotal;
  String? discountedPrice;
  String? productName;
  String? variantName;
  String? paymentMethod;
  String? finalTotal;
  String? orderNumber;
  String? cityId;
  String? cityName;
  String? deliveryBoyName;
  String? deliveryBoyMobile;
  String? productId;
  String? measurement;
  String? stockUnitId;
  String? orderStatusName;
  ReturnItem? returnItem;

  ReturnOrderDetailData(
      {this.id,
      this.userId,
      this.productVariantId,
      this.orderId,
      this.orderItemId,
      this.reason,
      this.status,
      this.remarks,
      this.deliveryBoyId,
      this.cancellationReason,
      this.createdAt,
      this.updatedAt,
      this.customerName,
      this.customerMobile,
      this.quantity,
      this.price,
      this.subTotal,
      this.discountedPrice,
      this.productName,
      this.variantName,
      this.paymentMethod,
      this.finalTotal,
      this.orderNumber,
      this.cityId,
      this.cityName,
      this.deliveryBoyName,
      this.deliveryBoyMobile,
      this.productId,
      this.measurement,
      this.stockUnitId,
      this.orderStatusName,
      this.returnItem});

  ReturnOrderDetailData.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    userId = (json['user_id']??0).toString();
    productVariantId = (json['product_variant_id']??0).toString();
    orderId = (json['order_id']??0).toString();
    orderItemId = (json['order_item_id']??0).toString();
    reason = json['reason']?? "";
    status = (json['status']??0).toString();
    remarks = (json['remarks']=="null" || json['remarks']==null)?"":json['remarks'];
    deliveryBoyId = (json['delivery_boy_id']??0).toString();
    cancellationReason = json['cancellation_reason']?? "";
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    customerName = json['customer_name']?? "";
    customerMobile = json['customer_mobile']?? "";
    quantity = (json['quantity']??0).toString();
    price = (json['price']??0).toString();
    subTotal = (json['sub_total']??0).toString();
    discountedPrice = (json['discounted_price']??0).toString();
    productName = json['product_name']?? "";
    variantName = json['variant_name']?? "";
    paymentMethod = json['payment_method']?? "";
    finalTotal = (json['final_total'] ?? 0).toString();
    orderNumber = (json['order_number']??0).toString();
    cityId = (json['city_id'] ?? 0).toString();
    cityName = json['city_name'] ?? "";
    deliveryBoyName = json['delivery_boy_name']?? "";
    deliveryBoyMobile = json['delivery_boy_mobile']?? "";
    productId = (json['product_id']??0).toString();
    measurement = (json['measurement']??0).toString();
    stockUnitId = (json['stock_unit_id']??0).toString();
    orderStatusName = json['order_status_name']?? "";
    returnItem = json['return_item'] != null
        ? new ReturnItem.fromJson(json['return_item'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['product_variant_id'] = this.productVariantId;
    data['order_id'] = this.orderId;
    data['order_item_id'] = this.orderItemId;
    data['reason'] = this.reason;
    data['status'] = this.status;
    data['remarks'] = this.remarks;
    data['delivery_boy_id'] = this.deliveryBoyId;
    data['cancellation_reason'] = this.cancellationReason;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['customer_name'] = this.customerName;
    data['customer_mobile'] = this.customerMobile;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['sub_total'] = this.subTotal;
    data['discounted_price'] = this.discountedPrice;
    data['product_name'] = this.productName;
    data['variant_name'] = this.variantName;
    data['payment_method'] = this.paymentMethod;
    data['final_total'] = this.finalTotal;
    data['order_number'] = this.orderNumber;
    data['city_id'] = this.cityId;
    data['city_name'] = this.cityName;
    data['delivery_boy_name'] = this.deliveryBoyName;
    data['delivery_boy_mobile'] = this.deliveryBoyMobile;
    data['product_id'] = this.productId;
    data['measurement'] = this.measurement;
    data['stock_unit_id'] = this.stockUnitId;
    data['order_status_name'] = this.orderStatusName;
    if (this.returnItem != null) {
      data['return_item'] = this.returnItem!.toJson();
    }
    return data;
  }
}

class ReturnItem {
  String? id;
  String? userId;
  String? orderId;
  String? ordersId;
  String? productName;
  String? variantName;
  String? productVariantId;
  String? deliveryBoyId;
  String? quantity;
  String? price;
  String? discountedPrice;
  String? taxAmount;
  String? taxPercentage;
  String? discount;
  String? subTotal;
  String? refundAmount;
  String? status;
  String? activeStatus;
  String? cancellationReason;
  String? canceledAt;
  String? sellerId;
  String? isCredited;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? mobile;
  String? total;
  String? deliveryCharge;
  String? promoCode;
  String? promoDiscount;
  String? walletBalance;
  String? finalTotal;
  String? paymentMethod;
  String? address;
  String? deliveryTime;
  String? userName;
  String? orderStatus;
  String? sellerName;
  String? productId;
  String? returnStatus;
  String? returnDays;
  String? image;
  String? statusName;
  String? amountToRefund;

  ReturnItem(
      {this.id,
      this.userId,
      this.orderId,
      this.ordersId,
      this.productName,
      this.variantName,
      this.productVariantId,
      this.deliveryBoyId,
      this.quantity,
      this.price,
      this.discountedPrice,
      this.taxAmount,
      this.taxPercentage,
      this.discount,
      this.subTotal,
      this.refundAmount,
      this.status,
      this.activeStatus,
      this.cancellationReason,
      this.canceledAt,
      this.sellerId,
      this.isCredited,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.mobile,
      this.total,
      this.deliveryCharge,
      this.promoCode,
      this.promoDiscount,
      this.walletBalance,
      this.finalTotal,
      this.paymentMethod,
      this.address,
      this.deliveryTime,
      this.userName,
      this.orderStatus,
      this.sellerName,
      this.productId,
      this.returnStatus,
      this.returnDays,
      this.image,
      this.statusName,
      this.amountToRefund});

  ReturnItem.fromJson(Map<String, dynamic> json) {
    id = (json['id']??0).toString();
    userId = (json['user_id']??0).toString();
    orderId = (json['order_id']??0).toString();
    ordersId = json['orders_id'] ?? "";
    productName = json['product_name']?? "";
    variantName = json['variant_name']?? "";
    productVariantId = (json['product_variant_id']??0).toString();
    deliveryBoyId = (json['delivery_boy_id']??0).toString();
    quantity = (json['quantity']??0).toString();
    price = (json['price']??0).toString();
    discountedPrice = (json['discounted_price']??0).toString();
    taxAmount = (json['tax_amount']??0).toString();
    taxPercentage = (json['tax_percentage']??0).toString();
    discount = (json['discount']??0).toString();
    subTotal = (json['sub_total']??0).toString();
    refundAmount = (json['refund_amount']??0).toString();
    status = json['status']?? "";
    activeStatus = (json['active_status']??0).toString();
    cancellationReason = json['cancellation_reason']?? "";
    canceledAt = json['canceled_at'] ?? "";
    sellerId = (json['seller_id']??0).toString();
    isCredited = (json['is_credited']??0).toString();
    createdAt = json['created_at'] ?? "";
    updatedAt = json['updated_at'] ?? "";
    deletedAt = json['deleted_at'] ?? "";
    mobile = json['mobile'] ?? "";
    total = (json['total']??0).toString();
    deliveryCharge = (json['delivery_charge']??0).toString();
    promoCode = json['promo_code']?? "";
    promoDiscount = (json['promo_discount']??0).toString();
    walletBalance = (json['wallet_balance']??0).toString();
    finalTotal = (json['final_total']??0).toString();
    paymentMethod = json['payment_method']?? "";
    address = json['address']?? "";
    deliveryTime = json['delivery_time']?? "";
    userName = json['user_name']?? "";
    orderStatus = json['order_status']?? "";
    sellerName = json['seller_name']?? "";
    productId = (json['product_id']??0).toString();
    returnStatus = (json['return_status']??0).toString();
    returnDays = (json['return_days']??0).toString();
    image = json['image'] ?? "";
    statusName = json['status_name']?? "";
    amountToRefund = (json['amount_to_refund']??0).toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['user_id'] = this.userId;
    data['order_id'] = this.orderId;
    data['orders_id'] = this.ordersId;
    data['product_name'] = this.productName;
    data['variant_name'] = this.variantName;
    data['product_variant_id'] = this.productVariantId;
    data['delivery_boy_id'] = this.deliveryBoyId;
    data['quantity'] = this.quantity;
    data['price'] = this.price;
    data['discounted_price'] = this.discountedPrice;
    data['tax_amount'] = this.taxAmount;
    data['tax_percentage'] = this.taxPercentage;
    data['discount'] = this.discount;
    data['sub_total'] = this.subTotal;
    data['refund_amount'] = this.refundAmount;
    data['status'] = this.status;
    data['active_status'] = this.activeStatus;
    data['cancellation_reason'] = this.cancellationReason;
    data['canceled_at'] = this.canceledAt;
    data['seller_id'] = this.sellerId;
    data['is_credited'] = this.isCredited;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    data['deleted_at'] = this.deletedAt;
    data['mobile'] = this.mobile;
    data['total'] = this.total;
    data['delivery_charge'] = this.deliveryCharge;
    data['promo_code'] = this.promoCode;
    data['promo_discount'] = this.promoDiscount;
    data['wallet_balance'] = this.walletBalance;
    data['final_total'] = this.finalTotal;
    data['payment_method'] = this.paymentMethod;
    data['address'] = this.address;
    data['delivery_time'] = this.deliveryTime;
    data['user_name'] = this.userName;
    data['order_status'] = this.orderStatus;
    data['seller_name'] = this.sellerName;
    data['product_id'] = this.productId;
    data['return_status'] = this.returnStatus;
    data['return_days'] = this.returnDays;
    data['image'] = this.image;
    data['status_name'] = this.statusName;
    data['amount_to_refund'] = this.amountToRefund;
    return data;
  }
}