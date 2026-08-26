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

  /// Server-side: productId -> wishlist entry id (delete ke liye).
  static final Map<int, int> _serverIds = {};

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

  /// Storage se wishlist items lao.
  static List<HomeDealOfTheDayModel> loadWishlistItems() {
    try {
      final raw = _staticStorage.read(_prefsKey);
      if (raw is String && raw.isNotEmpty) {
        final List list = jsonDecode(raw) as List;
        return list
            .map((e) => HomeDealOfTheDayModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
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
        final localOnly = localItems
            .where((e) => !serverProductIds.contains(e.id))
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

        _serverIds
          ..clear()
          ..addEntries(serverItems
              .where((e) => e.productId != null && e.wishlistId != null)
              .map((e) => MapEntry(e.productId!, e.wishlistId!)));

        // server ki list ko source-of-truth maano — local me replace kar do.
        await _saveAll(serverItems.map((e) => e.toDealModel()).toList());
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

  /// Item remove karo — local turant + logged-in ho to server par bhi.
  static Future<void> removeWishlistItem(int id) async {
    final items = loadWishlistItems()..removeWhere((e) => e.id == id);
    await _saveAll(items);

    if (!_isLoggedIn) return;
    try {
      await ensureServerSync();
      final entryId = _serverIds[id];
      if (entryId == null) return; // server par tha hi nahi
      final res = await ApiService().request(
        endpoint: ApiEndpoints.deleteWishlist,
        method: ApiMethod.delete,
        queryParams: {'id': entryId},
        fromJson: (json) => json,
      );
      if (res.isSuccess) {
        _serverIds.remove(id);
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
