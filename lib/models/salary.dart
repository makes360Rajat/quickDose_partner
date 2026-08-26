class SalaryData {
  String? id;
  String? amount;
  String? message;
  String? paidOn;
  String? deliveryBoyName;

  SalaryData({this.id, this.amount, this.message, this.paidOn, this.deliveryBoyName});

  SalaryData.fromJson(Map<String, dynamic> json) {
    id = (json['id']?? 0).toString();
    amount = json['amount']??"";
    message = json['message']??"";
    paidOn = json['paid_on']??"";
    deliveryBoyName = json['delivery_boy_name']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['amount'] = this.amount;
    data['message'] = this.message;
    data['paid_on'] = this.paidOn;
    data['delivery_boy_name'] = this.deliveryBoyName;
    return data;
  }
}
