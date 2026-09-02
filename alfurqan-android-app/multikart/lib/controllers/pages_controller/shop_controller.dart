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
  String sortField = "created_at"; // backend ke known-safe: created_at | price
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

  /// GetAllProductsFront api call.
  /// [reset] = true -> page 1 se fresh list, false -> agla page (pagination / load more)
  getProducts({bool reset = false}) async {
    if (reset) {
      currentPage = 1;
      hasMore = true;
      productList = [];
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
        "page": currentPage,
        "paginate": 12,
        "status": 1,
        "field": sortField,
        "price": priceRange,
        "category": categoryFilter,
        "tag": "",
        "sort": sortDirection,
        "sortBy": sortDirection,
        "rating": rating,
        "attribute": attribute,
      },
      fromJson: (json) => ProductListResponseModel.fromJson(json),
    );

    isLoadingProducts = false;
    isLoadingMore = false;

    if (res.isSuccess && res.data != null) {
      productList.addAll(res.data!.data);
      // NOTE: live api ka last_page hamesha 1 aata hai (backend bug), isliye
      // hasMore us par bharosa nahi karte — poora page (12) aaya to agla
      // page bhi assume karo.
      hasMore = res.data!.hasMore || res.data!.data.length >= 12;
    }

    update();
  }

  /// Pagination / infinite scroll - list ke end tak pahochte hi agla page load karo.
  loadMoreProducts() {
    if (!hasMore || isLoadingMore) return;
    currentPage += 1;
    getProducts();
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
