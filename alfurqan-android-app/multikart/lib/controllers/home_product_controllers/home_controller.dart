import '../../config.dart';
import '../../models/category_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

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

    subCategoryList(0, 1);
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


    update();
    return !isLiked;
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
    loginWidth = ScreenUtil().screenWidth;
    loginHeight = 500.w;
    update();
  }
}
