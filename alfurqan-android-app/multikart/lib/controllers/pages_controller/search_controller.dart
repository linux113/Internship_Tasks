import 'dart:convert';

import '../../config.dart';
import '../../models/product_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../services/category_cache.dart';

class SearchScreenController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController controller = TextEditingController();
  int selectRecommended = 0;
  List recommendedList = [];
  List innerCategoryProduct = [];

  // ---------------- Real "Recent Search" (user ki asli searches) ----------------
  // Pehle yaha fashion demo items ("Pink Hoodie" etc) aate the — ab user
  // jo bhi actually search karke product kholta hai wahi yaha save/dikhta
  // hai (SharedPreferences me, app band karne ke baad bhi bana rehta hai).
  List<String> recentSearches = [];
  static const String _recentKey = 'recent_searches';
  final _storage = LocalStorage();

  // ---------------- Real search (client-side, abhi backend me search
  // param kaam nahi karta — isliye products lekar app me filter karte hai)
  List<ProductApiModel> _allApiProducts = [];
  List<HomeFindStyleCategoryModel> searchResults = [];
  List<ProductApiModel> searchResultApi = []; // card tap -> detail page ke liye
  bool isSearchLoading = false;
  String query = '';

  @override
  void onReady() {
    // FIX: pehle 1-2 sec ke liye FASHION demo chips (Denim/Skirts/Jeans)
    // flash hoti thin, phir real categories aati thin. Ab khaali start —
    // _loadRecommended() sirf real alfurqan.ae categories bharega.
    recommendedList = [];
    innerCategoryProduct = [];
    // har keystroke pe filter — widget me koi change nahi karna pada
    controller.addListener(() => onSearchChanged(controller.text));
    _loadRecentSearches();
    update();
    // "Recommended for you" chips fashion naam (Denim/Skirts) dikhati thin —
    // ab real alfurqan.ae categories se bharo.
    _loadRecommended();
    super.onReady();
  }

  /// Storage se recent searches lao (max 6 rakhte hai).
  void _loadRecentSearches() {
    try {
      final raw = _storage.read(_recentKey);
      if (raw is String && raw.isNotEmpty) {
        recentSearches =
            (jsonDecode(raw) as List).map((e) => e.toString()).toList();
      }
    } catch (_) {}
  }

  /// Nayi search sabse upar add karo (duplicate pehle hata kar), max 6 tak.
  Future<void> saveRecentSearch(String q) async {
    final query = q.trim();
    if (query.isEmpty) return;
    recentSearches.remove(query);
    recentSearches.insert(0, query);
    if (recentSearches.length > 6) {
      recentSearches = recentSearches.take(6).toList();
    }
    await _storage.write(_recentKey, jsonEncode(recentSearches));
    update();
  }

  /// ✕ dabane par ek recent search hatao.
  Future<void> removeRecentSearch(String q) async {
    recentSearches.remove(q);
    await _storage.write(_recentKey, jsonEncode(recentSearches));
    update();
  }

  /// Recommended chips <- real top categories (tap = us category ka shop page).
  Future<void> _loadRecommended() async {
    await CategoryCache.ensureLoaded();
    if (CategoryCache.items.isNotEmpty) {
      recommendedList = CategoryCache.items
          .take(6)
          .map((c) => {
                'title': c.name ?? '',
                'slug': c.slug ?? '',
                'isSelected': false,
              })
          .toList();
      update();
    }
  }

  /// Saare products ek baar fetch karke cache karo (paginate=50 pages loop).
  Future<void> _loadAllProducts() async {
    if (_allApiProducts.isNotEmpty) return;
    // flaky mobile network ke liye — pehla page hi fail ho to 1 retry
    for (var attempt = 0; attempt < 2 && _allApiProducts.isEmpty; attempt++) {
      await _fetchAllPagesOnce();
      if (_allApiProducts.isEmpty && attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }
  }

  Future<void> _fetchAllPagesOnce() async {
    int page = 1;
    while (page <= 6) {
      final res = await ApiService().request<ProductListResponseModel>(
        endpoint: ApiEndpoints.productList,
        method: ApiMethod.get,
        queryParams: {
          "page": page,
          "paginate": 50,
          "status": 1,
          "field": "created_at",
          "price": "",
          "category": "",
          "tag": "",
          "sort": "desc",
          "sortBy": "desc",
          "rating": "",
          "attribute": "",
        },
        fromJson: (json) => ProductListResponseModel.fromJson(json),
      );
      if (!res.isSuccess || res.data == null) break;
      _allApiProducts.addAll(res.data!.data);
      if (res.data!.data.length < 50) break; // aakhri page
      page++;
    }
  }

  /// Products load na ho paye (internet/api issue) to ye true hoga — UI
  /// "No products found" ki jagah sahi error dikhayega.
  bool loadFailed = false;

  /// Textfield me type karte hi call hota hai — name/description me filter.
  Future<void> onSearchChanged(String text) async {
    final q = text.trim();
    if (q == query) return;
    query = q;
    if (query.isEmpty) {
      searchResults = [];
      searchResultApi = [];
      isSearchLoading = false;
      update();
      return;
    }
    isSearchLoading = true;
    loadFailed = false;
    update();
    await _loadAllProducts();
    if (_allApiProducts.isEmpty) {
      // api se kuch nahi aaya — user ko sahi error dikhao (aankh band karke
      // "no products" mat dikhao)
      loadFailed = true;
    }
    final lower = query.toLowerCase();
    searchResultApi = _allApiProducts
        .where((p) =>
            (p.name ?? '').toLowerCase().contains(lower) ||
            (p.shortDescription ?? '').toLowerCase().contains(lower))
        .toList();
    searchResults = searchResultApi.map((e) => e.toFindStyleModel()).toList();
    isSearchLoading = false;
    update();
  }

  //go to shop page
  goToShopPage(name) {
    appCtrl.isNotification = true;
    appCtrl.update();
    Get.toNamed(routeName.shopPage, arguments: {'slug': name, 'name': name});
  }
}
