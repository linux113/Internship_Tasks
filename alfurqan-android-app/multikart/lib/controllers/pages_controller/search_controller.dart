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
  List recentSearchList = [];
  List recommendedList = [];
  List innerCategoryProduct = [];

  // ---------------- Real search (client-side, abhi backend me search
  // param kaam nahi karta — isliye products lekar app me filter karte hai)
  List<ProductApiModel> _allApiProducts = [];
  List<HomeFindStyleCategoryModel> searchResults = [];
  List<ProductApiModel> searchResultApi = []; // card tap -> detail page ke liye
  bool isSearchLoading = false;
  String query = '';

  @override
  void onReady() {
    recentSearchList = AppArray().recentSearchList;
    recommendedList = AppArray().recommendedList;
    innerCategoryProduct = AppArray().innerCategoryProduct;
    // har keystroke pe filter — widget me koi change nahi karna pada
    controller.addListener(() => onSearchChanged(controller.text));
    update();
    // "Recommended for you" chips fashion naam (Denim/Skirts) dikhati thin —
    // ab real alfurqan.ae categories se bharo.
    _loadRecommended();
    super.onReady();
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
    update();
    await _loadAllProducts();
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
    Get.toNamed(routeName.shopPage, arguments: name);
  }
}
