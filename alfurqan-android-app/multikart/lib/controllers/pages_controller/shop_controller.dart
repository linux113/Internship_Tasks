import 'package:multikart/models/product_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

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

  // filters (baad me filter page se update honge)
  String priceRange = ""; // e.g. "100,500"
  String sortDirection = "asc"; // asc | desc
  String rating = "";
  String attribute = "";

  @override
  void onReady() {
    // TODO: implement onReady
    name = Get.arguments ?? "All".tr;
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

    // "All" select hai to category filter empty bhejo, warna slug bhejo.
    final String categoryFilter = (name == "All".tr) ? "" : name;

    final res = await ApiService().request<ProductListResponseModel>(
      endpoint: ApiEndpoints.productList,
      method: ApiMethod.get,
      queryParams: {
        "page": currentPage,
        "paginate": 12,
        "status": 1,
        "field": "created_at",
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
