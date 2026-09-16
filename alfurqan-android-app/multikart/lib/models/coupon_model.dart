class CouponModel {
  String? code;
  String? title;
  String? description;

  // 15/09 (user points 2/4): coupon ki TERMS bhi backend payload se parse
  // hoti hai (swagger Coupons schema: min_spend/start_date/end_date/
  // is_expired/is_first_order/amount/type) — card par T&C inline dikhta
  // hai aur APPLY tap par client-side gate lagti hai.
  double? minSpend; // is se kam order par coupon valid NAHI
  double? amount; // discount value (display ke liye)
  String? type; // 'percentage' / fixed
  String? startDate; // raw string (display wala)
  String? endDate;
  DateTime? startsAt; // parsed (gate ke liye)
  DateTime? endsAt;
  bool isFirstOrder = false; // sirf pehle order par valid

  CouponModel(
      {this.code,
      this.title,
      this.description,
      this.minSpend,
      this.amount,
      this.type,
      this.startDate,
      this.endDate,
      this.startsAt,
      this.endsAt,
      this.isFirstOrder = false});

  CouponModel.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    title = json['title'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['title'] = title;
    data['description'] = description;
    return data;
  }
}
