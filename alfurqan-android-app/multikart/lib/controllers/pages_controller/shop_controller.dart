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
    // Arguments: naya format {'slug':..., 'name':...} ya purana plain String.
    final args = Get.arguments;
    if (args is Map) {
      name = (args['slug'] ?? '').toString();
      displayName = (args['name'] ?? '').toString();
      if (name.isEmpty) name = "All".tr;
      if (displayName.isEmpty) displayName = name;
    } else {
      name = args ?? "All".tr;
      displayName = name;
    }
    categoryList = AppArray().categoryList;
    homeShopPageList = AppArray().homeShopPageList;
    appCtrl.isNotification = true;
    appCtrl.update();
    update();

    getProducts(reset: true);
    super.onReady();
  }

  // ---------------- Client-side filter/sort ----------------
  /// LIVE VERIFY (04/09/2026): backend GetAllProductsFront `field`, `sort`,
  /// `sortBy` aur `price` — SAB params poore IGNORE karta hai (sort=desc bhejne
  /// par bhi asc order aata tha; price=0,41 filter bhejne par bhi 45 wala
  /// product AA RAHA THA). Isliye ab filter+sort CLIENT-SIDE karte hai:
  /// ek baar me bada page (500) la kar locally sort/filter/slice karte hai.
  List<ProductApiModel> _fullList = []; // server se aayi poori (category tak)
  List<ProductApiModel> _filtered = []; // price+sort apply ke baad
  static const int _pageSize = 12;

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
    String categoryFilter = (name == "All".tr) ? "" : name;
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
    if(name == "All".tr) {
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
