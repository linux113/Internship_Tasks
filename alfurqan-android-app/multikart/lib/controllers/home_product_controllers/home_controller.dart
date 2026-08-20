import '../../config.dart';
import '../../models/category_api_model.dart';
import '../../models/product_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import 'wishlist_controller.dart';

class HomeController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final storage = LocalStorage();
  double loginWidth = 40.0;
  double loginHeight = 40.0;
  List<HomeCategoryModel> homeCategoryList = [];
  List<HomeBannerModel> bannerList = [];
  List<HomeDealOfTheDayModel> dealOfTheDayList = [];
  List findStyleCategory = [];
  List biggestDealBrandList = [];
  List offerCornerList = [];
  List<HomeFindStyleCategoryModel> findStyleCategoryList = [];
  List<HomeFindStyleCategoryModel> findStyleCategoryCategoryWiseList = [];
  List<HomeFindStyleCategoryModel> homeKidsCornerList = [];

  /// GetTopCategory se aayi real category list — home page ke category-row
  /// aur banner-carousel dono isi se banate hai. Slug ke through category
  /// tap karne par shop page open hota hai.
  List<CategoryApiModel> apiCategoryList = [];

  /// GetAllProductsFront se aaye real newest products (home sections ke liye)
  List<ProductApiModel> newestApiProducts = [];

  int current = 0;
  int selectedStyleCategory = 0;
  final CarouselController controller = CarouselController();
  bool selected = false;

  @override
  void onReady() async {
    getData();
    super.onReady();
  }
  getData() async {
    appCtrl.isShimmer = true;
    appCtrl.update();
    dealOfTheDayList = AppArray().homeDealOfTheDayList;
    findStyleCategory = AppArray().homeFindStyleCategory;
    findStyleCategoryList = AppArray().homeFindStyleCategoryList;
    biggestDealBrandList = AppArray().biggestDealBrandList;
    homeKidsCornerList = AppArray().homeKidsCornerList;
    offerCornerList = AppArray().offerCornerList;
    loginWidth = ScreenUtil().screenWidth;
    loginHeight = 500.w;
    update();
    await fetchTopCategories();
    await fetchHomeProducts();

    // Find-your-style ka initial grid = pehli real category chip
    if (findStyleCategory.isNotEmpty) {
      subCategoryList(0, findStyleCategory[0]['id']);
    } else {
      subCategoryList(0, 1);
    }
    update();
    await Future.delayed(DurationsClass.s1);
    appCtrl.isShimmer = false;
    appCtrl.update();
    Get.forceAppUpdate();
  }

  /// GetTopCategory api call — home page ki category-row aur
  /// banner-carousel isi ek response se populate hoti hai.
  Future<void> fetchTopCategories() async {
    final res = await ApiService().request<List<CategoryApiModel>>(
      endpoint: ApiEndpoints.topCategory,
      method: ApiMethod.get,
      fromJson: (json) => CategoryApiModel.listFromJson(json),
    );

    if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
      apiCategoryList = res.data!;
      homeCategoryList =
          apiCategoryList.map((e) => e.toHomeCategoryModel()).toList();
      bannerList =
          apiCategoryList.map((e) => e.toHomeBannerModel()).toList();
    } else {
      // api fail ho jaye to purana static/demo data hi fallback ke roop me dikhao
      homeCategoryList = AppArray().homeCategory;
      bannerList = AppArray().homeBanner;
    }
    update();
  }

  /// Home ke static sections (Deals of the Day / Find your Style /
  /// Kids Corner) ko real GetAllProductsFront ke newest products se
  /// dynamic banao. Api fail ho jaye to purana demo data hi rahega.
  Future<void> fetchHomeProducts() async {
    final res = await ApiService().request<ProductListResponseModel>(
      endpoint: ApiEndpoints.productList,
      method: ApiMethod.get,
      queryParams: {
        "page": 1,
        "paginate": 10,
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

    if (res.isSuccess && res.data != null && res.data!.data.isNotEmpty) {
      newestApiProducts = res.data!.data;

      // Deals of the Day <- real newest products
      dealOfTheDayList =
          newestApiProducts.map((p) => p.toDealOfTheDayModel()).toList();

      // Find your Style products <- real newest products (categoryId ke sath)
      findStyleCategoryList =
          newestApiProducts.map((p) => p.toFindStyleModel()).toList();

      // Find your Style chips <- real top categories
      if (apiCategoryList.isNotEmpty) {
        findStyleCategory = apiCategoryList
            .map((c) => {'id': c.id, 'title': c.name ?? ''})
            .toList();
      }

      // Kids corner horizontal list <- real products
      homeKidsCornerList = List.of(findStyleCategoryList);
    }
    update();
  }

  /// Home ke kisi bhi product card (deals/find-style/kids) ka tap —
  /// id se real ProductApiModel dhoond kar detail page pe le jao
  /// (na mile to purana demo detail fallback khulega).
  openProductById(int id) {
    ProductApiModel? found;
    for (final p in newestApiProducts) {
      if (p.id == id) {
        found = p;
        break;
      }
    }
    appCtrl.goToProductDetail(arguments: found);
  }

  /// Home category chip / banner tap karne par shop page open karo,
  /// asli category ka slug bhej ke (jaise CategoryController me hota hai).
  goToCategoryProducts(String? slug) {
    if (slug == null || slug.isEmpty) return;
    appCtrl.isHeart = true;
    appCtrl.isCart = true;
    appCtrl.isShare = false;
    appCtrl.isSearch = false;
    appCtrl.isNotification = true;
    appCtrl.update();
    Get.toNamed(routeName.shopPage, arguments: slug);
  }


  Future<bool> toggleWishlist(
      int productId, bool isLiked, String source) async {
    if (source == "findStyle") {
      for (var item in findStyleCategoryList) {
        if (item.id == productId) {
          item.isFav = !isLiked;
        }
      }
    }

    if (source == "kids") {
      for (var item in homeKidsCornerList) {
        if (item.id == productId) {
          item.isFav = !isLiked;
        }
      }
    }
    if (source == "dealsOfTheDay") {
      for (var item in dealOfTheDayList) {
        if (item.id == productId) {
          item.isFav = !isLiked;
        }
      }
    }
    // update similar products
    if (Get.isRegistered<ProductDetailController>()) {
      final productCtrl = Get.find<ProductDetailController>();

      for (var item in productCtrl.similarList) {
        if (item.id == productId) {
          item.isFav = !isLiked;
        }
      }

      productCtrl.update();
    }


    // local wishlist (SharedPreferences) me persist karo — ab heart tap
    // karne par wishlist actually save hoti hai, sirf UI flag nahi badalta.
    final bool newVal = !isLiked;
    HomeDealOfTheDayModel? entry;
    if (source == "dealsOfTheDay") {
      for (var item in dealOfTheDayList) {
        if (item.id == productId) entry = item;
      }
    } else {
      final src = source == "kids" ? homeKidsCornerList : findStyleCategoryList;
      for (var item in src) {
        if (item.id == productId) {
          entry = HomeDealOfTheDayModel(
            id: item.id,
            name: item.name,
            image: item.image,
            byWhom: 'مكتبة الفرقان',
            discount: item.discount,
            isFav: newVal,
            mrp: item.totalPrice,
            totalPrice: item.mrp,
            isTrending: false,
          );
        }
      }
    }
    if (newVal && entry != null) {
      WishlistController.saveWishlistItem(entry);
    } else {
      WishlistController.removeWishlistItem(productId);
    }
    // wishlist screen khuli ho to refresh kar do
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().refreshFromStorage();
    }

    update();
    return !isLiked;
  }

  /// Card-data se wishlist toggle — ye SOURCE independent hai.
  /// Pehle `toggleWishlist(id, isLiked, source)` sirf home ki lists me dhundhta
  /// tha — isliye SHOP / SEARCH page ke product cards ka heart tap karne par
  /// item kabhi wishlist me save hi nahi hota tha. Ab card ka pura data
  /// (name/image/price) seedha yaha milta hai, to kisi bhi screen ka
  /// product wishlist me save hota hai.
  Future<bool> toggleWishlistData(
      HomeFindStyleCategoryModel data, bool isLiked) async {
    final bool newVal = !isLiked;
    data.isFav = newVal;

    // home/detail ki kisi bhi list me same id dikhe to uska heart bhi sync karo
    for (var item in findStyleCategoryList) {
      if (item.id == data.id) item.isFav = newVal;
    }
    for (var item in homeKidsCornerList) {
      if (item.id == data.id) item.isFav = newVal;
    }
    for (var item in dealOfTheDayList) {
      if (item.id == data.id) item.isFav = newVal;
    }
    if (Get.isRegistered<ProductDetailController>()) {
      final productCtrl = Get.find<ProductDetailController>();
      for (var item in productCtrl.similarList) {
        if (item.id == data.id) item.isFav = newVal;
      }
      productCtrl.update();
    }

    if (newVal) {
      await WishlistController.saveWishlistItem(
        HomeDealOfTheDayModel(
          id: data.id,
          name: data.name,
          image: data.image,
          byWhom: 'مكتبة الفرقان',
          discount: data.discount,
          isFav: true,
          mrp: data.totalPrice, // selling price
          totalPrice: data.mrp, // original (struck) price
          isTrending: false,
        ),
      );
    } else {
      await WishlistController.removeWishlistItem(data.id);
    }
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().refreshFromStorage();
    }

    update();
    return newVal;
  }

    //sub category list by category id
  subCategoryList(index, categoryId) async {
    loginWidth = 40.0;
    loginHeight = 40.0;

    update();
    await Future.delayed(DurationsClass.s1);
    selected = !selected;
    findStyleCategoryCategoryWiseList = [];
    selectedStyleCategory = index;

    update();
    for (var i = 0; i < findStyleCategoryList.length; i++) {
      if (categoryId.toString() ==
          findStyleCategoryList[i].categoryId.toString()) {
        findStyleCategoryCategoryWiseList.add(findStyleCategoryList[i]);
      }
    }
    // agar is category me koi item na mile (kam products me possible),
    // to grid khaali na dikhe — saare products dikha do
    if (findStyleCategoryCategoryWiseList.isEmpty) {
      findStyleCategoryCategoryWiseList = List.of(findStyleCategoryList);
    }
    loginWidth = ScreenUtil().screenWidth;
    loginHeight = 500.w;
    update();
  }
}
