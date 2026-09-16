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
    // FIX (Issue #1): pehle products pool SIRF pehle keystroke PAR load
    // hota tha — user type karta aur 2-4 sec spinner/silence ("search kaam
    // nahi kar raha"). Ab page khulte hi background me pool load shuru.
    _loadAllProducts();
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

  /// Arabic/Urdu/Farsi text NORMALIZATION (point 8/9 root fix).
  /// Query aur product fields DONO isi se guzarte hai, phir plain
  /// contains() kaam kar jata hai. Latin lowercase bhi (SKU/slug).
  /// NOTE: code points Python se VERIFY kiye hue hai — FARSI ye (U+06CC)
  /// -> Arabi ye (U+064A) waghera saare 13 roop mappings exact hai.
  String _normSearch(String? s) {
    var t = (s ?? '').toLowerCase();
    // harakat/tashkeel (064B-0652), dagger alef (0670), Quranic marks
    // (06D6-06ED), tatweel (0640), zero-width/bidi marks hatao
    t = t.replaceAll(
        RegExp(
            '[\u0640-\u0652\u0670\u06D6-\u06ED\u200C\u200D\u200E\u200F\uFEFF]'),
        '');
    // keyboard roop -> ek canonical Arabi rup (dono sides same hote hai):
    // \u0623 \u0625 \u0622 \u0671 -> \u0627 (alef ke roop)
    // \u06CC FARSI ye / \u0649 / \u06D2 URDU bari ye / \u0626 -> \u064A
    // \u06A9 FARSI ke -> \u0643 | \u0624 -> \u0648
    // \u0629 taa-marbuta / \u06C1 / \u06BE -> \u0647
    const roop = {
      '\u0623': '\u0627',
      '\u0625': '\u0627',
      '\u0622': '\u0627',
      '\u0671': '\u0627',
      '\u06CC': '\u064A',
      '\u0649': '\u064A',
      '\u06D2': '\u064A',
      '\u0626': '\u064A',
      '\u06A9': '\u0643',
      '\u0624': '\u0648',
      '\u0629': '\u0647',
      '\u06C1': '\u0647',
      '\u06BE': '\u0647',
    };
    roop.forEach((from, to) {
      t = t.replaceAll(from, to);
    });
    // Arabic-Indic + Extended digits -> latin (Arabic keyboard se SKU)
    for (var i = 0; i < 10; i++) {
      t = t.replaceAll(String.fromCharCode(0x0660 + i), '$i');
      t = t.replaceAll(String.fromCharCode(0x06F0 + i), '$i');
    }
    return t.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

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
    final nq = _normSearch(query);
    // FIX (Issue #1): pehle SIRF naam + short_description me match hota tha
    // — English queries (quran/seerah/fiqh) ya SKU code (F0010069) type
    // karne par kuch NAHI milta tha, kyunki book names Arabic me hai.
    // Ab SKU, slug (English hota hai), description aur CATEGORY names bhi
    // match hote hai — English/Arabic dono queries kaam karengi.
    //
    // FIX (15/09 user points 8/9 — END-TO-END deep root cause LIVE se):
    // user "الحدیث" search ki — usme ye FARSI/URDU keyboard wali ی
    // (U+06CC) hai jabki catalog Arabic ي (U+064A) use karta hai. Live
    // probe: alfurqan.ae ka search FARSI ye pe total:0 deta hai, Arabic
    // ي se sahi results. Matlab SERVER bhi FARSI ye pe khaali tha aur app
    // ki client-side search bhi exact-raw match karti thi — match kabhi
    // nahi hota. Ab DONO sides (query AUR product fields) _normSearch se
    // ek hi canonical form me aane ke BAAD compare hote hai (Farsi ye/ke,
    // Urdu bari ye/do-chashmi he, alef roop, taa-marbuta, tashkil,
    // tatweel, zero-width marks — sab normalize). Ab الحدیث/الحديث
    // dono likhne par الحديث ki books milengi.
    searchResultApi = _allApiProducts.where((p) {
      if (_normSearch(p.name).contains(nq)) return true;
      if (_normSearch(p.shortDescription).contains(nq)) return true;
      if (_normSearch(p.description).contains(nq)) return true;
      if (_normSearch(p.sku).contains(nq)) return true;
      if (_normSearch(p.slug).contains(nq)) return true;
      for (final c in p.categories) {
        if (_normSearch(c.name).contains(nq)) return true;
        if (_normSearch(c.slug).contains(nq)) return true;
      }
      return false;
    }).toList();
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
