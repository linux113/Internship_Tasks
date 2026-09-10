import 'package:multikart/models/product_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';
import 'package:multikart/services/category_cache.dart';

import '../../config.dart';
import '../../views/pages/filter/filter.dart';

class ShopController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  TextEditingController controller = TextEditingController();
  List<HomeFindStyleCategoryModel> homeShopPageList = [];
  List<CategoryModel> categoryList = [];
  CategoryModel? categoryModel;
  final dashboardCtrl = Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());
  String name = "";
  final storage = LocalStorage();

  // ---------------- Real product list (GetAllProductsFront) ----------------
  List<ProductApiModel> productList = [];
  bool isLoadingProducts = false;
  bool isLoadingMore = false;
  int currentPage = 1;
  bool hasMore = true;

  // filters (filter page se update hote hai — applyToShop/resetFilter)
  String priceRange = ""; // e.g. "100,500"
  String sortDirection = "asc"; // asc | desc
  // "" (Recommended = natural/newest order) | "created_at" (What's New) | "price"
  // NOTE: sort+price CLIENT-SIDE hota hai — backend ye params IGNORE karta
  // hai (live verify: sort=desc par bhi asc order; price=0,41 par bhi 45
  // wala product aa raha tha).
  String sortField = "";
  String rating = "";
  String attribute = "";

  /// Title ke liye REAL name (slug nahi — slug url-friendly hota hai, user
  /// ko padhne me ajeeb lagta hai). Filter ke liye `name`/slug hi use hota hai.
  String displayName = "";

  @override
  void onReady() {
    // NOTE: purana arg-parse + getProducts seedha yaha tha — ab openCategory()
    // karta hai, taaki ROUTE dobara khulne par bhi (See All, category chip,
    // banner) naye arguments se refresh ho (GetX controller REUSE karta hai
    // isliye onReady sirf PEHLI baar chalta hai — yahi wajah thi ki See All
    // par purani/empty category atki rehti thi: "0 record", 10/09).
    categoryList = AppArray().categoryList;
    homeShopPageList = AppArray().homeShopPageList;
    appCtrl.isNotification = true;
    appCtrl.update();
    update();

    // SHOP page ka search box LIVE filter kare (Issue #10 — pehle controller
    // ka listener kahi attached hi nahi tha; type karo aur kuch na ho).
    controller.addListener(_onSearchText);

    openCategory(Get.arguments, force: true);
    super.onReady();
  }

  /// Shop page me type kiya text — catalog ke ANDAR filter (price/sort ke
  /// upar layer). Har keystroke par client-side.
  void _onSearchText() {
    final q = controller.text.trim();
    if (q == searchQuery) return;
    searchQuery = q;
    applyClientFilters();
  }

  /// YE page kis category/All ke liye khula — har route-entry par call hota
  /// hai (shop_page postFrame se). Same args par REFETCH nahi (loop-safe);
  /// naye args par fresh fetch.
  void openCategory(dynamic args, {bool force = false}) {
    String newName = '';
    String newDisplay = '';
    if (args is Map) {
      newName = (args['slug'] ?? '').toString();
      newDisplay = (args['name'] ?? '').toString();
    } else {
      newName = args?.toString() ?? '';
    }
    if (newName.isEmpty) newName = 'All';
    if (newDisplay.isEmpty || newDisplay == newName) {
      newDisplay = newName == 'All' ? 'All'.tr : newName;
    }
    final key = '$newName|$newDisplay';
    if (!force && key == _lastOpenKey && _fullList.isNotEmpty) return;
    _lastOpenKey = key;
    name = newName;
    displayName = newDisplay;
    // naye page par purana search text atka na rahe
    if (searchQuery.isNotEmpty) {
      searchQuery = '';
      controller.clear();
    }
    update();
    getProducts(reset: true);
  }

  /// "All" user ki language me kuch bhi ho (ya raw "All" arg aaya ho) —
  /// category filter aakhir me bhejna hi nahi.
  bool get _isAll => name == 'All' || name == 'All'.tr;

  String _lastOpenKey = '__never__';

  // ---------------- Client-side filter/sort ----------------
  /// LIVE VERIFY (04/09/2026): backend GetAllProductsFront `field`, `sort`,
  /// `sortBy` aur `price` — SAB params poore IGNORE karta hai (sort=desc bhejne
  /// par bhi asc order aata tha; price=0,41 filter bhejne par bhi 45 wala
  /// product AA RAHA THA). Isliye ab filter+sort CLIENT-SIDE karte hai:
  /// ek baar me bada page (500) la kar locally sort/filter/slice karte hai.
  List<ProductApiModel> _fullList = []; // server se aayi poori (category tak)
  List<ProductApiModel> _filtered = []; // price+sort+search apply ke baad
  static const int _pageSize = 12;

  /// Shop page ke search box ka LIVE text (Issue #10 — 10/09).
  String searchQuery = '';

  /// Loaded catalog ki max price (filter slider ki range isi se banti hai —
  /// 08/09; min 100, 50 ke steps me rounded-up).
  double get catalogMaxPrice {
    var m = 100.0;
    for (final p in _fullList) {
      if (p.finalPrice > m) m = p.finalPrice;
    }
    return (m / 50).ceil() * 50.0;
  }

  /// ALREADY-LOADED catalog par filter/sort dobara apply — APPLY dabate hi
  /// TURANT (network refetch nahi, spinner flash nahi). Agar list abhi load
  /// hi nahi hui to full getProducts.
  void applyClientFilters() {
    if (_fullList.isEmpty) {
      getProducts(reset: true);
      return;
    }
    _applyFiltersAndSort();
    currentPage = 1;
    hasMore = _filtered.length > _pageSize;
    productList = _filtered.take(_pageSize).toList();
    update();
  }

  /// price filter + sort apply karke _filtered set karo.
  void _applyFiltersAndSort() {
    List<ProductApiModel> list = List<ProductApiModel>.from(_fullList);

    // ---- price range ("min,max") — REAL finalPrice (sale_price>0 ? sale : price)
    if (priceRange.isNotEmpty) {
      final parts = priceRange.split(',');
      double min = 0, max = double.infinity;
      if (parts.isNotEmpty) {
        min = double.tryParse(parts[0].trim()) ?? 0;
      }
      if (parts.length > 1) {
        max = double.tryParse(parts[1].trim()) ?? double.infinity;
      }
      if (min > 0 || max < double.infinity) {
        list = list
            .where((p) => p.finalPrice >= min && p.finalPrice <= max)
            .toList();
      }
    }

    // ---- search text (shop page ka box) — name/desc/SKU/slug/category me
    // match (English+Arabic dono). Client-side kyunki backend ke
    // field/sort/price params server-side IGNORE hote hai (live verify).
    if (searchQuery.isNotEmpty) {
      final lower = searchQuery.toLowerCase();
      list = list.where((p) {
        if ((p.name ?? '').toLowerCase().contains(lower)) return true;
        if ((p.shortDescription ?? '').toLowerCase().contains(lower)) {
          return true;
        }
        if ((p.description ?? '').toLowerCase().contains(lower)) return true;
        if ((p.sku ?? '').toLowerCase().contains(lower)) return true;
        if ((p.slug ?? '').toLowerCase().contains(lower)) return true;
        for (final c in p.categories) {
          if ((c.name ?? '').toLowerCase().contains(lower)) return true;
          if ((c.slug ?? '').toLowerCase().contains(lower)) return true;
        }
        return false;
      }).toList();
    }

    // ---- sort
    int byIdDesc(ProductApiModel a, ProductApiModel b) =>
        (b.id ?? 0).compareTo(a.id ?? 0);
    int byCreated(ProductApiModel a, ProductApiModel b) {
      final ad = DateTime.tryParse(a.createdAt ?? '');
      final bd = DateTime.tryParse(b.createdAt ?? '');
      if (ad == null && bd == null) return byIdDesc(a, b);
      if (ad == null) return 1;
      if (bd == null) return -1;
      return ad.compareTo(bd);
    }

    switch (sortField) {
      case "price":
        list.sort((a, b) => sortDirection == "desc"
            ? b.finalPrice.compareTo(a.finalPrice)
            : a.finalPrice.compareTo(b.finalPrice));
        break;
      case "created_at":
        list.sort((a, b) => sortDirection == "desc"
            ? -byCreated(a, b)
            : byCreated(a, b));
        break;
      default:
        // "Recommended" = backend ka NATURAL order (naye products pehle)
        // — pehle bhi users yahi order dekhte the, isliye kuch sort nahi.
        break;
    }

    _filtered = list;
  }

  /// GetAllProductsFront api call.
  /// [reset] = true -> page 1 se fresh list, false -> agla page (pagination / load more)
  getProducts({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      hasMore = true;
      productList = [];
      _fullList = [];
      _filtered = [];
      isLoadingProducts = true;
    } else {
      if (!hasMore || isLoadingMore) return;
      isLoadingMore = true;
    }
    update();

    // "All" select hai to category filter empty bhejo, warna SLUG bhejo.
    // FIX: kabhi-kabhi yaha slug ki jagah category ka NAAM (ya purani demo
    // tiles ke fashion titles) aa jata tha — backend naam nahi pehchanta
    // aur shop page khaali dikhne lagta tha. Ab cached categories se
    // naam -> slug convert kar lete hai.
    String categoryFilter = _isAll ? "" : name;
    if (categoryFilter.isNotEmpty) {
      await CategoryCache.ensureLoaded();
      final match = CategoryCache.resolve(categoryFilter);
      if (match != null) categoryFilter = match.slug ?? categoryFilter;
    }

    final res = await ApiService().request<ProductListResponseModel>(
      endpoint: ApiEndpoints.productList,
      method: ApiMethod.get,
      queryParams: {
        "page": 1,
        // Ek hi baar me poora catalog — sort/price CLIENT-SIDE karne ke
        // liye poori list chahiye (backend ke sort/price params kaam hi
        // nahi karte — live verify).
        "paginate": 500,
        "status": 1,
        "field": "",
        "price": "",
        "category": categoryFilter,
        "tag": "",
        "sort": "",
        "sortBy": "",
        "rating": "",
        "attribute": "",
      },
      fromJson: (json) => ProductListResponseModel.fromJson(json),
    );

    isLoadingProducts = false;
    isLoadingMore = false;

    if (res.isSuccess && res.data != null) {
      // duplicate ids hata do (backend kabhi repeated rows bhej deta hai)
      final seen = <int>{};
      _fullList = [
        for (final p in res.data!.data)
          if (p.id == null || seen.add(p.id!)) p
      ];
      _applyFiltersAndSort();
      hasMore = _filtered.length > _pageSize;
      productList = _filtered.take(_pageSize).toList();
    } else {
      hasMore = false;
    }

    update();
  }

  /// Pagination / infinite scroll — ab LOCAL (poori list pehle se aa chuki
  /// hai; agla slice turant milta hai, network call nahi).
  loadMoreProducts() {
    if (!hasMore || isLoadingMore) return;
    isLoadingMore = true;
    update();
    final next = currentPage + 1;
    final end = next * _pageSize;
    productList = _filtered.take(end).toList();
    currentPage = next;
    hasMore = _filtered.length > productList.length;
    isLoadingMore = false;
    update();
  }

  //filter page route
  Route createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => Filter(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  //bottom change
  bottomNavigationChange(val, context) async {
    Get.back();
    Get.back();
    dashboardCtrl.bottomNavigationChange(val, context);
  }

  //go back to home page
  goToHomePage() async {
    if(_isAll) {
      appCtrl.goToHome();

      await storage.write(Session.selectedIndex, 0);
      appCtrl.selectedIndex = 0;
    }else{
      appCtrl.isNotification = false;
      await storage.write(Session.selectedIndex, 1);
      appCtrl.selectedIndex = 1;
    }
    update();
    appCtrl.update();
    Get.back();
  }
}
