import 'dart:developer';

import '../models/json_parse_utils.dart';
import 'api_endpoints.dart';
import 'api_service.dart';
import 'local_storage_service.dart';

/// TAX rates ka DYNAMIC source — swagger (10/09/2026 live) me
/// GET /api/Taxes/GetAllTaxes mila: har tax = {id, name, rate, status}.
/// Products me sirf tax_id aata hai (rate nahi — GetAllProductsFront ka
/// nested "tax" object front serializer me AATA hi nahi, live verify).
/// Isliye id→rate map ISI api se banta hai; login maangti hai (guest 401).
///
/// REAL proof ki ye zaroori hai: order #1078 (10/09) ka breakdown —
/// Subtotal AED 65 + Tax AED 11.70 = EXACT 18% (65 × 0.18 = 11.70) —
/// catalog ke saare products tax_id:3 rakhte hai, isliye store-wide rate
/// deterministic hai. Cart/payment ka tax row ab guesswork nahi — yehi
/// rate use karta hai.
///
/// Best-effort silent service: fail hone par khaali map rehta hai aur UI
/// tax row HIDE rakhti hai (fake tax kabhi nahi dikhate). Rates LocalStorage
/// me cache hote hai — agle app-open par login se PEHLE bhi row aa sakti
/// hai (pehli successful sync ke baad).
class TaxService {
  TaxService._();

  /// tax_id → rate (percent, jaise 18.0)
  static final Map<int, double> rateById = {};

  /// tax_id → tax naam (label/debug ke liye)
  static final Map<int, String> nameById = {};
  static bool _loading = false;
  static bool _tried = false;

  static const String _cacheKey = 'tax_rates_v1';

  /// Device-cache se rates wapas lao (network se pehle — instant).
  static void _restoreCache() {
    if (rateById.isNotEmpty) return;
    try {
      final raw = LocalStorage().read(_cacheKey);
      if (raw is Map) {
        raw.forEach((k, v) {
          final id = int.tryParse(k.toString()) ?? 0;
          final rate = jsonToDouble(v);
          if (id > 0 && rate != null && rate > 0) rateById[id] = rate;
        });
      }
    } catch (_) {}
  }

  /// Ek baar server se laake cache karo. force=true par dobara try.
  static Future<void> load({bool force = false}) async {
    _restoreCache();
    if (_loading) return;
    if (_tried && rateById.isNotEmpty && !force) return;
    _loading = true;
    try {
      final res = await ApiService().request<Map<int, double>>(
        endpoint: '${ApiEndpoints.taxes}?paginate=50',
        method: ApiMethod.get,
        fromJson: (json) {
          // Shape lenient: List seedha, ya {data:[...]} / {Data:{data:[...]}}
          dynamic raw = json;
          for (var i = 0; i < 6 && raw is Map; i++) {
            // kabhi-kabhi {data:{data:[...]}} / {items:[...]} nested aata hai
            if ((raw as Map).containsKey('data') ||
                raw.containsKey('Data') ||
                raw.containsKey('items') ||
                raw.containsKey('Items')) {
              raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
            } else {
              break;
            }
          }
          if (raw is! List) return <int, double>{};
          final out = <int, double>{};
          for (final e in raw) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            final id = jsonToInt(m['id'] ?? m['Id']) ?? 0;
            final rate = jsonToDouble(m['rate'] ?? m['Rate']);
            final status = m['status'] ?? m['Status'];
            // status false wala tax inactive — skip (sirf explicit false
            // skip; key na ho / string ho to maan lo active).
            if (status == false) continue;
            if (id > 0 && rate != null && rate > 0) {
              out[id] = rate;
              final nm = jsonToString(m['name'] ?? m['Name']);
              if (nm != null && nm.isNotEmpty) nameById[id] = nm;
            }
          }
          return out;
        },
      );
      if (res.isSuccess && (res.data ?? {}).isNotEmpty) {
        rateById
          ..clear()
          ..addAll(res.data!);
        try {
          await LocalStorage().write(_cacheKey,
              rateById.map((k, v) => MapEntry(k.toString(), v.toString())));
        } catch (_) {}
      }
      // Device-console visibility (remote debug): tax rates aaye ya nahi
      log('[TaxService] code=${res.code} success=${res.isSuccess} '
          'rates=$rateById');
      _tried = true;
    } catch (_) {
      _tried = true;
    }
    _loading = false;
  }

  /// tax_id se rate (percent). Cache restore bhi kar deta hai.
  static double? rateFor(int? taxId) {
    _restoreCache();
    if (taxId == null || taxId <= 0) return null;
    return rateById[taxId];
  }

  /// Store me agar EK hi active tax rate hai (ye store aisa hi hai —
  /// poora catalog tax_id:3 × 18%), to product ka tax_id unknown ho tab
  /// bhi wahi rate lagana SAFE hai (order #1078 math se verified).
  /// Alag-alag rates wali dukkan me null (unknown) rahega — fake guess nahi.
  static double? get singleActiveRate {
    _restoreCache();
    if (rateById.isEmpty) return null;
    final rates = rateById.values.toSet();
    if (rates.length == 1) return rates.first;
    return null;
  }
}
