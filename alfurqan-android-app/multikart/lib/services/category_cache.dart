import '../models/category_api_model.dart';
import 'api_endpoints.dart';
import 'api_service.dart';

/// App me kai jagah (shop page filter, trending categories, search ke
/// recommended chips) top categories chahiye hoti hai. Har jagah alag se
/// api call na karni pade, isliye ek chhota sa in-memory cache rakha hai —
/// GetTopCategory ek baar call hoga aur result yaha rahega.
class CategoryCache {
  CategoryCache._();

  static List<CategoryApiModel> items = [];
  static bool _loading = false;
  static int _attempts = 0;
  static const int _maxAttempts = 3;

  /// Pehli baar call par api se categories load karta hai, baad me cached
  /// list hi use hoti hai. Api fail ho jaye to agli baar phir try karega
  /// (max 3 attempts — isse zyada nahi, taaki har tap par api call na chale).
  static Future<void> ensureLoaded() async {
    if (items.isNotEmpty || _loading || _attempts >= _maxAttempts) return;
    _loading = true;
    _attempts++;
    try {
      final res = await ApiService().request<List<CategoryApiModel>>(
        endpoint: ApiEndpoints.topCategory,
        method: ApiMethod.get,
        fromJson: (json) => CategoryApiModel.listFromJson(json),
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        items = res.data!;
      }
    } catch (_) {
      // ignore — cache khaali hi rahega, agli baar phir try hoga
    } finally {
      _loading = false;
    }
  }

  /// Diye gaye text (slug YA category ka naam dono chalenge) se matching
  /// category dhoondo. Shop page jaisi jagah par jaha kabhi-kabhi slug ki
  /// jagah naam aa jata hai, usko sahi slug me convert karne ke liye.
  static CategoryApiModel? resolve(String text) {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return null;
    for (final c in items) {
      if ((c.slug ?? '').toLowerCase() == t) return c;
    }
    for (final c in items) {
      if ((c.name ?? '').trim().toLowerCase() == t) return c;
    }
    return null;
  }
}
