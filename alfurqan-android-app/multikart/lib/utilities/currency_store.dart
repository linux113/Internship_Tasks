import 'dart:convert';

import '../services/local_storage_service.dart';

/// User ka selected currency (symbol + base(AED) se rate) local storage me
/// THEEK TARAH persist karne ke liye chhota helper.
///
/// Pehle pura Dart Map `toString()` karke save ho jata tha — jo wapas read
/// karne par Map nahi rehta tha, aur agli currency change par app
/// crash ho jati thi (`currencyVal[code]` ek String par call hota tha).
/// Ab sirf {code, symbol, rate} JSON string ki tarah save hota hai.
class StoredCurrency {
  final String code;
  final String symbol;
  final double rate;

  const StoredCurrency({
    required this.code,
    required this.symbol,
    required this.rate,
  });
}

class CurrencyStore {
  static const String _key = 'currencyVal';

  /// Stored currency wapas lao (kuch save nahi hai / purana galat format
  /// pada hai to null — caller default AED use kare).
  static StoredCurrency? read() {
    try {
      final raw = LocalStorage().read(_key);
      Map<dynamic, dynamic>? map;
      if (raw is Map) {
        map = raw;
      } else if (raw is String && raw.startsWith('{')) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) map = decoded;
      }
      if (map == null) return null;

      final code = map['code']?.toString() ?? 'AED';
      final symbol = map['symbol']?.toString() ?? 'AED';
      final rateRaw = map['rate'] ?? map[code] ?? 1;
      final rate = double.tryParse(rateRaw.toString()) ?? 1.0;
      return StoredCurrency(code: code, symbol: symbol, rate: rate);
    } catch (_) {
      return null;
    }
  }

  /// Naya selection save karo (sirf zaruri 3 fields — JSON string).
  static Future<void> save({
    required String code,
    required String symbol,
    required double rate,
  }) {
    return LocalStorage().write(
      _key,
      jsonEncode({'code': code, 'symbol': symbol, 'rate': rate}),
    );
  }
}
