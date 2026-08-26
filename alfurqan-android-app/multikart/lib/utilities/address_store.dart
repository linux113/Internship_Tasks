import 'dart:convert';

import '../config.dart';
import '../models/location_model.dart';

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
}
