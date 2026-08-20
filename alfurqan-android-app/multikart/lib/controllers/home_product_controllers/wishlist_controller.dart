import 'dart:convert';

import '../../config.dart';

/// Wishlist ab static demo nahi hai — user jab bhi kisi product card ka
/// heart tap karta hai, item yaha SharedPreferences (JSON string) me
/// save hota hai, aur wishlist page yahi se read karti hai.
/// (Backend ka wishlist api aane par bas yahi methods api se replace ho jayenge.)
class WishlistController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final storage = LocalStorage();
  CartModel? cartModelList;
  List<HomeDealOfTheDayModel> wishlist = [];

  static const String _prefsKey = 'local_wishlist';
  static final LocalStorage _staticStorage = LocalStorage();

  @override
  void onReady() {
    wishlist = loadWishlistItems();
    update();
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

  /// Item add karo (pehle se ho to replace).
  static Future<void> saveWishlistItem(HomeDealOfTheDayModel item) async {
    final items = loadWishlistItems();
    items.removeWhere((e) => e.id == item.id);
    item.isFav = true;
    items.add(item);
    await _saveAll(items);
  }

  /// Item remove karo.
  static Future<void> removeWishlistItem(int id) async {
    final items = loadWishlistItems()..removeWhere((e) => e.id == id);
    await _saveAll(items);
  }

  /// Wishlist screen ka data storage se dobara load karke UI refresh karo.
  void refreshFromStorage() {
    wishlist = loadWishlistItems();
    update();
  }

  //common bottom sheet
  bottomSheetLayout(text) {
    Get.bottomSheet(
      CommonBottomSheet(text:text),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }
}
