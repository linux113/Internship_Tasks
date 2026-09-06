import '../models/json_parse_utils.dart';
import 'api_endpoints.dart';
import 'api_service.dart';

/// ORDERS ka DYNAMIC status list — backend team (Entwino) ne 06/09/2026 ko
/// bataya: order status values (Pending, In Process, Ready to ship, Shipped
/// ...) ab STATIC nahi hai — table se aate hai. Isliye jaha bhi app me order
/// status ka dropdown ya status-flow dikhta hai, data ISI api
/// (Orders/GetOrderStatus) se aana chahiye.
///
/// Ye api login maangti hai (guest ko 401). Best-effort silent service:
/// fail hone par khaali list rehti hai aur UI apne purane fallback
/// (order row ka status / activities timeline) par chalti rahti hai.
class OrderStatusService {
  OrderStatusService._();

  /// Cached steps: {id:int, name:String, sequence:int, slug:String}
  /// (sequence ke hisaab se sorted — step 1 sabse pehle).
  static List<Map<String, dynamic>> statuses = [];
  static bool _loading = false;
  static bool _tried = false;

  /// Ek baar server se laake cache karo. force=true par dobara try.
  static Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (_tried && statuses.isNotEmpty && !force) return;
    _loading = true;
    try {
      final res = await ApiService().request<List<Map<String, dynamic>>>(
        endpoint: ApiEndpoints.orderStatus,
        method: ApiMethod.get,
        fromJson: (json) {
          // Shape lenient: List seedha, ya {data:[...]} / {Data:{data:[...]}}
          dynamic raw = json;
          for (var i = 0; i < 4 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['result'];
          }
          if (raw is! List) return <Map<String, dynamic>>[];
          final out = <Map<String, dynamic>>[];
          for (final e in raw) {
            if (e is! Map) continue;
            final m = Map<String, dynamic>.from(e);
            final name = jsonToString(
                    m['name'] ?? m['Name'] ?? m['title'] ?? m['status']) ??
                '';
            if (name.isEmpty || name == 'true' || name == 'false') continue;
            out.add({
              'id': jsonToInt(m['id'] ?? m['Id']) ?? 0,
              'name': name,
              'sequence': jsonToInt(m['sequence'] ??
                      m['Sequence'] ??
                      m['order'] ??
                      m['sort_order']) ??
                  0,
              'slug': jsonToString(m['slug'] ?? m['Slug']) ?? '',
            });
          }
          return out;
        },
      );
      if (res.isSuccess && (res.data ?? []).isNotEmpty) {
        statuses = res.data!;
        statuses.sort((a, b) =>
            (a['sequence'] as int).compareTo(b['sequence'] as int));
      }
      _tried = true;
    } catch (_) {
      _tried = true;
    }
    _loading = false;
  }

  /// id / name / slug se display-name. Match na mile to '' —
  /// caller apna fallback use kare.
  static String nameFor(dynamic v) {
    if (v == null) return '';
    final s = v.toString().trim();
    if (s.isEmpty) return '';
    for (final st in statuses) {
      if (st['id'].toString() == s) return st['name'] as String;
      if ((st['name'] as String).toLowerCase() == s.toLowerCase()) {
        return st['name'] as String;
      }
      final slug = st['slug'] as String;
      if (slug.isNotEmpty && slug.toLowerCase() == s.toLowerCase()) {
        return st['name'] as String;
      }
    }
    return '';
  }
}
