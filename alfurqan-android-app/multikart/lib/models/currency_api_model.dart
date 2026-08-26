import 'json_parse_utils.dart';

/// GetAllCurrenciesFront (web/CoreFront/GetAllCurrenciesFront) se aayi ek currency.
/// Response envelope: { data: { data: [ ...currencies ] } } (pagination wala).
class CurrencyApiModel {
  final int? id;
  final String code; // "AED" (trim karke — "EUR " jaisi trailing space hata kar)
  final String symbol;
  final int noOfDecimal;
  final double exchangeRate; // backend jaisa bheje waisa (normalization controller me)
  final String symbolPosition;
  final bool status;

  CurrencyApiModel({
    this.id,
    this.code = '',
    this.symbol = '',
    this.noOfDecimal = 2,
    this.exchangeRate = 1,
    this.symbolPosition = '',
    this.status = true,
  });

  factory CurrencyApiModel.fromJson(Map<String, dynamic> json) {
    return CurrencyApiModel(
      id: jsonToInt(json['id']),
      code: (jsonToString(json['code']) ?? '').trim(),
      symbol: jsonToString(json['symbol']) ?? '',
      noOfDecimal: jsonToInt(json['no_of_decimal']) ?? 2,
      exchangeRate: jsonToDouble(json['exchange_rate']) ?? 1,
      symbolPosition: jsonToString(json['symbol_position']) ?? '',
      status: jsonToBool(json['status']) ?? true,
    );
  }

  /// ApiService `data` node deta hai — wo {current_page, data:[...]} map bhi
  /// ho sakta hai ya seedha list bhi — dono handle karo.
  static List<CurrencyApiModel> listFromJson(dynamic json) {
    dynamic rawList;
    if (json is Map) {
      rawList = json['data'] ?? json['Data'];
    } else {
      rawList = json;
    }
    if (rawList is List) {
      return rawList
          .where((e) => e is Map)
          .map((e) =>
              CurrencyApiModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .where((e) => e.code.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
