import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// GetStorage ki jagah ab SharedPreferences use ho raha hai.
///
/// GetStorage jaisa hi simple API (read/write/remove/erase) rakha gaya hai,
/// taaki purane code me sirf `GetStorage()` -> `LocalStorage()` badalna pade,
/// baaki sab kuch (Session keys, calling pattern) same rahe.
///
/// IMPORTANT: `LocalStorage.init()` ko `main()` me `runApp()` se pehle
/// (jaise pehle `GetStorage.init()` call hota tha) ek baar await karna hai.
class LocalStorage {
  LocalStorage._internal();

  static final LocalStorage _instance = LocalStorage._internal();

  factory LocalStorage() => _instance;

  static SharedPreferences? _prefs;

  /// App start hote hi ek baar call karo (main.dart me).
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(
      _prefs != null,
      'LocalStorage.init() call nahi hua. main() me runApp() se pehle '
      '`await LocalStorage.init();` add karo.',
    );
    return _prefs!;
  }

  /// JSON-encoded Map/List values is marker ke saath store hote hai — read()
  /// inhe wapas asli Map/List me decode kar deta hai. Plain strings ko touch
  /// nahi kiya jata (decode fail = original string hi return hoti hai).
  static const String _jsonMarker = '@@json@@';

  /// GetStorage.read(key) jaisa - jo bhi type save kiya tha wahi dynamic value milegi.
  ///
  /// DEEP-FIX (08/09 — "rating dene par phir bhi 0" ka ASLI jad): pehle
  /// Map/List values `value.toString()` se save hoti thi (jaise
  /// '{494: 5.0}') — read() par `raw is Map` kabhi true hota hi nahi tha,
  /// isliye my_ratings AUR cart_snapshot_v2 dono device par DEAD the.
  /// Ab Map/List JSON-encode hokar save hoti hai aur yaha decode ho jati hai.
  dynamic read(String key) {
    final v = _p.get(key);
    if (v is String) {
      if (v.startsWith(_jsonMarker)) {
        try {
          return jsonDecode(v.substring(_jsonMarker.length));
        } catch (_) {
          return v;
        }
      }
    }
    // NOTE: bina-marker strings deliberately touch nahi karte — address
    // store / wishlist / recent-searches JAISI features khud jsonEncode kar
    // ke RAW STRING save karti hai aur read par `raw is String` expect
    // karti hai; unhe decode kar dena unka parse tod dega.
    return v;
  }

  /// GetStorage.write(key, value) jaisa - value ke runtime type ke hisaab se
  /// sahi SharedPreferences setter khud choose karta hai.
  Future<void> write(String key, dynamic value) async {
    if (value == null) {
      await _p.remove(key);
    } else if (value is String) {
      await _p.setString(key, value);
    } else if (value is bool) {
      await _p.setBool(key, value);
    } else if (value is int) {
      await _p.setInt(key, value);
    } else if (value is double) {
      await _p.setDouble(key, value);
    } else if (value is List<String>) {
      await _p.setStringList(key, value);
    } else if (value is Map || value is List) {
      // Map/List ko round-trip-able JSON string me save karo (read() decode karega).
      try {
        await _p.setString(key, _jsonMarker + jsonEncode(value));
      } catch (_) {
        await _p.setString(key, value.toString());
      }
    } else {
      // Koi complex/unknown type ho to string bana kar rakh do, taki data loss na ho.
      await _p.setString(key, value.toString());
    }
  }

  /// GetStorage.remove(key) jaisa.
  Future<void> remove(String key) => _p.remove(key);

  /// GetStorage.erase() jaisa - poora local storage clear kar deta hai.
  Future<void> erase() => _p.clear();
}
