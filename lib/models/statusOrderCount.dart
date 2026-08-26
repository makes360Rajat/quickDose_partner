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
