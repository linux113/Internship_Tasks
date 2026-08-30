import '../config.dart';

class OrderHistoryModel {
  String? orderDay;
  List<DaysWiseList>? daysWiseList;
  // Server order ka REAL id — detail page (GetOrder?id=) kholne ke liye.
  int? orderId;

  OrderHistoryModel({this.orderDay, this.daysWiseList, this.orderId});

  OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    orderDay = json['orderDay'];
    orderId = json['orderId'] is num
        ? (json['orderId'] as num).toInt()
        : int.tryParse(json['orderId']?.toString() ?? '');
    if (json['daysWiseList'] != null) {
      daysWiseList = <DaysWiseList>[];
      json['daysWiseList'].forEach((v) {
        daysWiseList!.add(DaysWiseList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['orderDay'] = orderDay;
    data['orderId'] = orderId;
    if (daysWiseList != null) {
      data['daysWiseList'] = daysWiseList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

