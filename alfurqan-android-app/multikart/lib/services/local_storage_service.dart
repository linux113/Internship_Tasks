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

  /// GetStorage.read(key) jaisa - jo bhi type save kiya tha wahi dynamic value milegi.
  dynamic read(String key) => _p.get(key);

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
