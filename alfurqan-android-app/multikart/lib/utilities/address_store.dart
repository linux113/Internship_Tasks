import 'dart:convert';

import '../config.dart';
import '../models/location_model.dart';
import '../services/api_endpoints.dart';
import '../services/api_service.dart';

/// Saved addresses ka LOCAL store (SharedPreferences).
/// Server pe save (Location/AddAddress) ke baad yaha bhi copy rakhte hai
/// taaki Saved Address page turant dikha sake (Get-addresses api abhi
/// backend se di nahi gayi hai).
class AddressStore {
  AddressStore._();

  static const String _prefsKey = 'local_addresses';
  static final LocalStorage _storage = LocalStorage();

  static List<AddressModel> load() {
    try {
      final raw = _storage.read(_prefsKey);
      if (raw is String && raw.isNotEmpty) {
        final List list = jsonDecode(raw) as List;
        return list
            .map((e) => AddressModel.fromLocalJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static Future<void> saveAll(List<AddressModel> items) {
    return _storage.write(
        _prefsKey, jsonEncode(items.map((e) => e.toLocalJson()).toList()));
  }

  static Future<void> remove(int id) async {
    final items = load()..removeWhere((e) => e.id == id);
    await saveAll(items);
  }

  /// Server (Location/GetAllAddress) se fresh addresses la kar local store
  /// se MERGE karo — yahi shared sync hai: Saved Address page AUR checkout
  /// Delivery Details page dono isi ko call karte hai (08/09 — Delivery
  /// page pehle sirf LOCAL padhta tha: fresh install / store-clear par
  /// waha addresses KABHI nahi aate the chahe server par pade ho).
  /// Return: merged list; null = logged-out / fail / server-khaali (local
  /// store ko waise hi rakho).
  static Future<List<AddressModel>?> syncFromServer() async {
    final storage = LocalStorage();
    final loggedIn = (storage.read(Session.isLogin) ?? false) == true;
    if (!loggedIn) return null;
    try {
      final res = await ApiService().request<List<AddressModel>>(
        endpoint: ApiEndpoints.getAllAddress,
        method: ApiMethod.get,
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
          }
          if (raw is! List) return <AddressModel>[];
          return raw
              .where((e) => e is Map)
              .map((e) => AddressModel.fromServerJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        var serverList = res.data!;
        final rawUid = storage.read('id');
        final uid = rawUid is num
            ? rawUid.toInt()
            : (int.tryParse(rawUid?.toString() ?? '') ?? 0);
        if (serverList.any((e) => (e.userId ?? 0) != 0)) {
          serverList =
              serverList.where((e) => (e.userId ?? 0) == uid).toList();
        }
        if (serverList.isEmpty) return null;

        // local-only (kabhi server par save na hue) addresses append karo
        final localOnly = load()
            .where((l) =>
                !l.fromServer &&
                !serverList.any((s) =>
                    s.street == l.street &&
                    s.pincode == l.pincode &&
                    s.phone == l.phone))
            .toList();
        final merged = [...serverList, ...localOnly];
        await saveAll(merged);
        return merged;
      }
    } catch (_) {}
    return null;
  }
}
