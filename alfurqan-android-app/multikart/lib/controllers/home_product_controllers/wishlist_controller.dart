import 'dart:convert';

import '../../config.dart';
import '../../models/server_wishlist_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// Wishlist — LOCAL (guest ke liye, SharedPreferences) + SERVER (logged-in
/// user ke liye, api/Wishlist/*) dono ke sath.
///
/// ⭐ Design rule (v1.0.8): LOCAL LIST KABHI SHRINK NAHI HOTI sirf isliye ki
/// server response chhota/ajeeb aaya.
///  - GetWishlist kabhi-kabhi turant naya item nahi dikhata (ya shape badalta
///    hai) — isliye sync UNION karta hai: server items + local-only items,
///    replace nahi. Top par "4 par atak gaya" bug isi replace se aata tha.
///  - Add: local turant + server POST; response se entry id register kar
///    lete hai (remove ke liye) — poore list ko dobara fetch kar overwrite
///    nahi karte.
///  - Remove: us product ki SARI server entries delete.
///  - Pehli sync par guest-local items server par push ho jate hai (guards
///    se duplicates nahi bante).
class WishlistController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final storage = LocalStorage();
  CartModel? cartModelList;
  List<HomeDealOfTheDayModel> wishlist = [];

  static const String _prefsKey = 'local_wishlist';
  static final LocalStorage _staticStorage = LocalStorage();

  /// Server-side: displayId(productId ya wishlistId) -> wishlist entry ids.
  static final Map<int, List<int>> _serverIds = {};

  /// Ek baar server se sync ho chuki hai ya nahi.
  static bool _serverSynced = false;

  static bool _syncRunning = false;

  static bool get _isLoggedIn =>
      (_staticStorage.read(Session.isLogin) ?? false) == true;

  static int get _userId {
    final raw = _staticStorage.read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  @override
  void onReady() {
    wishlist = loadWishlistItems();
    update();
    // logged-in ho to server se bhi sync karo (background).
    ensureServerSync();
    super.onReady();
  }

  /// Storage se wishlist items lao — DUPLICATE id wale items sirf ek baar.
  static List<HomeDealOfTheDayModel> loadWishlistItems() {
    try {
      final raw = _staticStorage.read(_prefsKey);
      if (raw is String && raw.isNotEmpty) {
        final List list = jsonDecode(raw) as List;
        final seen = <int>{};
        final items = <HomeDealOfTheDayModel>[];
        for (final e in list) {
          if (e is! Map) continue;
          final item = HomeDealOfTheDayModel.fromJson(
              Map<String, dynamic>.from(e));
          if (seen.contains(item.id)) continue; // duplicate skip
          seen.add(item.id);
          items.add(item);
        }
        return items;
      }
    } catch (_) {}
    return [];
  }

  static Future<void> _saveAll(List<HomeDealOfTheDayModel> items) {
    return _staticStorage.write(
        _prefsKey, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  /// open wishlist screen / heart taps turant UI me dikh jaye.
  static void _notifyUi() {
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().refreshFromStorage();
    }
  }

  // ---------------------------------------------------------------------------
  // SERVER SYNC (api/Wishlist/*)
  // ---------------------------------------------------------------------------

  /// Logout par call karo — pichhle user ki server-cache saaf ho jaye.
  static void clearServerCache() {
    _serverIds.clear();
    _serverSynced = false;
  }

  /// Server se fresh wishlist entries lao. Request fail ho to null
  /// (EMPTY list ka matlab sach me khaali wishlist hai — alag cheez).
  static Future<List<ServerWishlistItem>?> _fetchServerWishlist() async {
    try {
      final res = await ApiService().request<List<ServerWishlistItem>>(
        endpoint: ApiEndpoints.getWishlist,
        method: ApiMethod.get,
        fromJson: (json) => ServerWishlistItem.listFromJson(json),
      );
      if (res.isSuccess && res.data != null) return res.data!;
    } catch (_) {}
    return null;
  }

  /// Ek server entry delete (best effort).
  static Future<bool> _deleteServerEntry(int entryId) async {
    try {
      final res = await ApiService().request(
        endpoint: ApiEndpoints.deleteWishlist,
        method: ApiMethod.delete,
        queryParams: {'id': entryId},
        fromJson: (json) => json,
      );
      return res.isSuccess;
    } catch (_) {
      return false;
    }
  }

  /// Ek product server par add (best effort) — response me mili entry id
  /// (ho to) wapas karta hai.
  static Future<int?> _postServerAdd(int productId) async {
    try {
      final res = await ApiService().request(
        endpoint: ApiEndpoints.addToWishlist,
        method: ApiMethod.post,
        data: {
          'id': 0,
          'consumer_id': _userId,
          'product_id': productId,
        },
        fromJson: (json) => json,
      );
      if (res.isSuccess) {
        if (res.data is Map) {
          final map = Map<String, dynamic>.from(res.data as Map);
          // response row ho ya {data:{row}} — dono se id/product_id nikalo
          int? entryId;
          int? pid;
          void scan(Map m) {
            entryId ??= _asInt(m['id'] ?? m['Id'] ?? m['wishlist_id']);
            pid ??= _asInt(m['product_id'] ?? m['productId'] ?? m['ProductId']);
            for (final k in const ['data', 'Data', 'item', 'Item']) {
              if (m[k] is Map) scan(Map<String, dynamic>.from(m[k] as Map));
            }
          }
          scan(map);
          // agar response kisi AURAT (aur product) ki hai to bharosa mat karo
          if (entryId != null && (pid == null || pid == productId)) {
            return entryId;
          }
        }
        return -1; // success par id nahi mili — entry id unknown
      }
    } catch (_) {}
    return null;
  }

  static int? _asInt(dynamic v) =>
      v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');

  /// Server rows se `_serverIds` map + deduped display list banao.
  /// Server par padi duplicate product entries clean bhi kar deta hai.
  static Future<List<ServerWishlistItem>> _processServerRows(
      List<ServerWishlistItem> serverItems) async {
    _serverIds.clear();
    for (final e in serverItems) {
      if (e.wishlistId == null) continue;
      _serverIds.putIfAbsent(e.displayId, () => []).add(e.wishlistId!);
    }

    final seenProducts = <int>{};
    final seenDisplay = <int>{};
    final unique = <ServerWishlistItem>[];
    final duplicateEntryIds = <int>[];
    for (final e in serverItems) {
      final pid = e.productId;
      if (pid != null) {
        if (seenProducts.contains(pid)) {
          if (e.wishlistId != null) duplicateEntryIds.add(e.wishlistId!);
          continue;
        }
        seenProducts.add(pid);
      }
      if (seenDisplay.contains(e.displayId)) continue;
      seenDisplay.add(e.displayId);
      unique.add(e);
    }
    // duplicate server entries background me clean karo
    for (final entryId in duplicateEntryIds) {
      await _deleteServerEntry(entryId);
    }
    if (duplicateEntryIds.isNotEmpty) {
      _serverIds.forEach((pid, ids) =>
          ids.removeWhere((id) => duplicateEntryIds.contains(id)));
      _serverIds.removeWhere((pid, ids) => ids.isEmpty);
    }
    return unique;
  }

  /// Zaroorat padi par server se ek baar sync karo.
  ///
  /// ⭐ UNION semantics: server ki list + local-only items MERGE hote hai —
  /// local list server response ki wajah se kabhi CHHOTI nahi hoti. Local-only
  /// items (guest favorites) server par push bhi ho jate hai.
  static Future<void> ensureServerSync() async {
    if (!_isLoggedIn || _serverSynced || _syncRunning) return;
    _syncRunning = true;
    try {
      final fetched = await _fetchServerWishlist();
      if (fetched == null) return; // network fail — local hi rahegi
      final uniqueServer = await _processServerRows(fetched);

      // ---- local-only items = server par NAHI dikhe (id/entryId/naam se) ----
      final localItems = loadWishlistItems();
      final serverPids =
          uniqueServer.map((e) => e.productId).whereType<int>().toSet();
      final serverEntryIds =
          uniqueServer.map((e) => e.wishlistId).whereType<int>().toSet();
      final serverNames = uniqueServer
          .map((e) => (e.name ?? '').trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toSet();
      final localOnly = localItems
          .where((e) =>
              !serverPids.contains(e.id) &&
              !serverEntryIds.contains(e.id) &&
              !serverNames.contains((e.name ?? '').trim().toLowerCase()))
          .toList();

      // ---- guest/fresh adds server par PUSH karo + entry ids register karo ----
      if (localOnly.isNotEmpty) {
        for (final item in localOnly) {
          final entryId = await _postServerAdd(item.id);
          if (entryId != null && entryId > 0) {
            _serverIds.putIfAbsent(item.id, () => []).add(entryId);
          }
        }
      }

      // ---- UNION merge: server items pehle, phir local-only ----
      final merged = <HomeDealOfTheDayModel>[];
      final seen = <int>{};
      for (final s in uniqueServer) {
        if (seen.add(s.displayId)) merged.add(s.toDealModel());
      }
      for (final l in localOnly) {
        if (seen.add(l.id)) merged.add(l);
      }

      await _saveAll(merged);
      _serverSynced = true;
      _notifyUi();
    } catch (_) {
      // koi bhi error — local list safe rahegi
    } finally {
      _syncRunning = false;
    }
  }

  /// Item add karo — local turant + logged-in ho to server par bhi.
  static Future<void> saveWishlistItem(HomeDealOfTheDayModel item) async {
    final items = loadWishlistItems();
    items.removeWhere((e) => e.id == item.id);
    item.isFav = true;
    items.add(item);
    await _saveAll(items);
    _notifyUi();

    if (!_isLoggedIn) return;
    try {
      // pehli baar ho to sync kar lo — guard ke baad hi duplicate POST nahi hoga.
      // (sync ke andar local-only push server par daal deta hai)
      await ensureServerSync();

      // server par pehle se (ya abhi push hokar) maujood hai?
      if (_serverIds.containsKey(item.id) &&
          (_serverIds[item.id]?.isNotEmpty ?? false)) {
        return;
      }

      final entryId = await _postServerAdd(item.id);
      if (entryId != null) {
        if (entryId > 0) {
          // exact entry id mil gayi — remove ab bina resync ke kaam karega
          _serverIds.putIfAbsent(item.id, () => []).add(entryId);
        } else {
          // success par id unknown — agli baar app open par sync theek kar lega
          _serverIds.putIfAbsent(item.id, () => []);
        }
        // ⭐ yaha full list REPLACE nahi karte — local list hamesha sahi rahegi.
      }
    } catch (_) {}
  }

  /// Item remove karo — local turant + logged-in ho to server se bhi.
  /// Server par us product ki SARI entries delete karte hai (duplicates samet).
  static Future<void> removeWishlistItem(int id) async {
    final items = loadWishlistItems()..removeWhere((e) => e.id == id);
    await _saveAll(items);
    _notifyUi();

    if (!_isLoggedIn) return;
    try {
      await ensureServerSync();
      var entryIds = _serverIds[id];

      // entry id pata nahi (is session me server par push hua)? ek fresh
      // fetch karke dobara dhoondo.
      if (entryIds == null || entryIds.isEmpty) {
        final fetched = await _fetchServerWishlist();
        if (fetched != null) {
          await _processServerRows(fetched);
          entryIds = _serverIds[id];
        }
      }
      if (entryIds == null || entryIds.isEmpty) return; // server par tha hi nahi

      for (final entryId in List<int>.from(entryIds)) {
        if (await _deleteServerEntry(entryId)) {
          entryIds.remove(entryId);
        }
      }
      if (entryIds.isEmpty) _serverIds.remove(id);
      // ⭐ delete ke baad bhi local list ko server se overwrite nahi karte —
      // local already sahi hai (item hat chuka hai).
    } catch (_) {}
  }

  /// Wishlist screen ka data storage se dobara load karke UI refresh karo.
  void refreshFromStorage() {
    wishlist = loadWishlistItems();
    update();
  }

  /// Wishlist screen ke "Remove" button se — storage se hata kar UI refresh.
  Future<void> removeItem(int id) async {
    await removeWishlistItem(id);
    refreshFromStorage();
  }

  //common bottom sheet
  bottomSheetLayout(text) {
    Get.bottomSheet(
      CommonBottomSheet(text: text),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }
}
