import 'dart:convert';

import '../../config.dart';
import '../../models/server_wishlist_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// Wishlist — LOCAL (guest ke liye, SharedPreferences) + SERVER (logged-in
/// user ke liye, api/Wishlist/*) dono ke sath.
///
/// Behavior:
///  - Guest: sirf local save (jaisa pehle tha).
///  - Logged-in: local turant update (UI fast rahe) + background me server
///    AddToWishlist / DeleteWishlist bhi sync hota hai.
///  - Login ke baad / pehli baar sync par server ki list hi source-of-truth
///    ban jati hai (server wali products local me aa jate hai).
///  - Delete ke liye backend ko wishlist ENTRY id chahiye (product id nahi) —
///    isliye `_serverIds` map me productId -> entryId rakha hai.
class WishlistController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final storage = LocalStorage();
  CartModel? cartModelList;
  List<HomeDealOfTheDayModel> wishlist = [];

  static const String _prefsKey = 'local_wishlist';
  static final LocalStorage _staticStorage = LocalStorage();

  /// Server-side: productId -> wishlist entry ids (delete ke liye).
  /// EK product ke server par DUPLICATE entries ho sakti hai (pehle ke sync
  /// bug se) — isliye LIST rakhte hai aur remove par SAB delete karte hai.
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

  /// Storage se wishlist items lao — DUPLICATE id wale items sirf ek baar
  /// rakho (warna remove ek par saare duplicate saath me hat jaate the).
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

  // ---------------------------------------------------------------------------
  // SERVER SYNC (api/Wishlist/*)
  // ---------------------------------------------------------------------------

  /// Logout par call karo — pichhle user ki server-cache saaf ho jaye.
  static void clearServerCache() {
    _serverIds.clear();
    _serverSynced = false;
  }

  /// Zaroorat padi par server se ek baar sync karo (ek se zyada parallel
  /// sync na chale isliye chhota lock hai).
  static Future<void> ensureServerSync() async {
    if (!_isLoggedIn || _serverSynced || _syncRunning) return;
    _syncRunning = true;
    try {
      final res = await ApiService().request<List<ServerWishlistItem>>(
        endpoint: ApiEndpoints.getWishlist,
        method: ApiMethod.get,
        fromJson: (json) => ServerWishlistItem.listFromJson(json),
      );
      if (res.isSuccess && res.data != null) {
        var serverItems = res.data!;

        // PEHLI sync par guest-local items jo server par nahi hai unhe pehle
        // server par PUSH kar do — warna local->server replace me wo gayab ho
        // jate (user ki pehle se like ki hui cheezein bachani hai).
        final localItems = loadWishlistItems();
        final serverProductIds =
            serverItems.map((e) => e.productId).whereType<int>().toSet();
        // naam bhi match karo (case-insensitive) — purane app version ki
        // galat-id wali local items dobara server par push na ho.
        final serverNames = serverItems
            .map((e) => (e.name ?? '').trim().toLowerCase())
            .where((e) => e.isNotEmpty)
            .toSet();
        // purane version me local item ki id WISHLIST ENTRY id hoti thi —
        // aise items server par pehle se maujood hai, dobara push mat karo.
        final serverEntryIds =
            serverItems.map((e) => e.wishlistId).whereType<int>().toSet();
        final localOnly = localItems
            .where((e) =>
                !serverProductIds.contains(e.id) &&
                !serverEntryIds.contains(e.id) &&
                !serverNames.contains((e.name ?? '').trim().toLowerCase()))
            .toList();
        if (localOnly.isNotEmpty) {
          for (final item in localOnly) {
            try {
              await ApiService().request(
                endpoint: ApiEndpoints.addToWishlist,
                method: ApiMethod.post,
                data: {
                  'id': 0,
                  'consumer_id': _userId,
                  'product_id': item.id,
                },
                fromJson: (json) => json,
              );
            } catch (_) {}
          }
          // push ke baad server se latest list dobara laao
          try {
            final res2 = await ApiService().request<List<ServerWishlistItem>>(
              endpoint: ApiEndpoints.getWishlist,
              method: ApiMethod.get,
              fromJson: (json) => ServerWishlistItem.listFromJson(json),
            );
            if (res2.isSuccess && res2.data != null) {
              serverItems = res2.data!;
            }
          } catch (_) {}
        }

        // productId -> SARI entry ids (duplicates samet) — delete ke kaam aayegi.
        _serverIds.clear();
        for (final e in serverItems) {
          if (e.productId == null || e.wishlistId == null) continue;
          _serverIds.putIfAbsent(e.productId!, () => []).add(e.wishlistId!);
        }

        // Display ke liye productId se DEDUPE — server par agar galti se ek
        // hi product 2-3 baar add ho gaya ho to list me sirf ek baar dikhe.
        // (Extra duplicate entries server se bhi clean kar dete hai.)
        final seen = <int>{};
        final unique = <ServerWishlistItem>[];
        final duplicateEntryIds = <int>[];
        for (final e in serverItems) {
          final pid = e.productId;
          if (pid != null) {
            if (seen.contains(pid)) {
              if (e.wishlistId != null) duplicateEntryIds.add(e.wishlistId!);
              continue;
            }
            seen.add(pid);
          }
          unique.add(e);
        }
        // background me duplicate server entries delete karo (best effort)
        for (final entryId in duplicateEntryIds) {
          try {
            await ApiService().request(
              endpoint: ApiEndpoints.deleteWishlist,
              method: ApiMethod.delete,
              queryParams: {'id': entryId},
              fromJson: (json) => json,
            );
          } catch (_) {}
        }
        // delete hue duplicates ko map se bhi hata do
        if (duplicateEntryIds.isNotEmpty) {
          _serverIds.forEach((pid, ids) =>
              ids.removeWhere((id) => duplicateEntryIds.contains(id)));
        }

        // server ki list ko source-of-truth maano — local me replace kar do.
        await _saveAll(unique.map((e) => e.toDealModel()).toList());
        _serverSynced = true;

        if (Get.isRegistered<WishlistController>()) {
          Get.find<WishlistController>().refreshFromStorage();
        }
      }
    } catch (_) {
      // network issue — next action par phir try hoga
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

    if (!_isLoggedIn) return;
    try {
      await ensureServerSync();
      // server par pehle se PRESENT ho to dobara add mat karo — warna same
      // product ki duplicate entries ban jaati hai (fir remove par confusion).
      if (_serverIds.containsKey(item.id) &&
          (_serverIds[item.id]?.isNotEmpty ?? false)) {
        return;
      }
      final res = await ApiService().request(
        endpoint: ApiEndpoints.addToWishlist,
        method: ApiMethod.post,
        data: {
          'id': 0,
          'consumer_id': _userId,
          'product_id': item.id,
        },
        fromJson: (json) => json,
      );
      if (res.isSuccess) {
        // naye entry ki exact id lene ke liye dobara sync kar lo
        _serverSynced = false;
        await ensureServerSync();
      }
    } catch (_) {}
  }

  /// Item remove karo — local turant + logged-in ho to server se bhi.
  /// Server par us product ki SARI entries delete karte hai (duplicates
  /// samet) — warna sync ke baad wahi item wapas aa jata tha.
  static Future<void> removeWishlistItem(int id) async {
    final items = loadWishlistItems()..removeWhere((e) => e.id == id);
    await _saveAll(items);

    if (!_isLoggedIn) return;
    try {
      await ensureServerSync();
      final entryIds = _serverIds[id];
      if (entryIds == null || entryIds.isEmpty) return; // server par tha hi nahi
      bool anyDeleted = false;
      for (final entryId in List<int>.from(entryIds)) {
        try {
          final res = await ApiService().request(
            endpoint: ApiEndpoints.deleteWishlist,
            method: ApiMethod.delete,
            queryParams: {'id': entryId},
            fromJson: (json) => json,
          );
          if (res.isSuccess) {
            entryIds.remove(entryId);
            anyDeleted = true;
          }
        } catch (_) {}
      }
      if (entryIds.isEmpty) _serverIds.remove(id);
      if (anyDeleted) {
        // server se fresh list laao taaki UI me koi stale/duplicate item
        // wapas na dikhe.
        _serverSynced = false;
        await ensureServerSync();
      }
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
