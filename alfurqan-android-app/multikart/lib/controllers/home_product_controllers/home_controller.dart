import '../../config.dart';
import '../../models/category_api_model.dart';
import '../../models/home_page_api_model.dart';
import '../../models/product_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../services/category_cache.dart';
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

  /// NAYE home api (GetHomePageDataApp) ne real data diya ya nahi.
  bool homeApiLoaded = false;

  /// Find Your Style ke chips yahi tabs hote hai (Trending/Top Picks/Featured...)
  List<FindYourMatchTab> matchTabs = [];

  /// Home ke SAARE sections ke api products (id -> detail lookup ke liye).
  List<ProductApiModel> homeApiProductsAll = [];

  /// --- API se aaye section titles/descriptions (hardcoded ki jagah) ---
  String dealsTitle = '';
  String dealsDescription = '';
  String trendingTitle = '';
  String trendingDescription = '';
  String matchSectionTitle = ''; // Find_Your_Match title (future; abhi API nahi bhejta)
  String matchSectionDescription = '';

  /// Offer_Banner.Banner_1 — pehla non-empty-image offer banner (bada banner,
  /// purane demo "Denim Wear Sales Starts In" timer ki jagah).
  HomePageBanner? mainOfferBanner;

  /// Baaki offer banners (Banner_2/3) — Offer Corner grid ke liye.
  List<HomePageBanner> offerCornerBanners = [];

  /// Real brands (sirf tab jab backend Brand.Status=true kare).
  List<HomePageBrand> brandList = [];

  static void _addUnique(List<ProductApiModel> list, ProductApiModel p) {
    if (p.id == null) return;
    if (!list.any((e) => e.id == p.id)) list.add(p);
  }

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
    // FIX (strict no-static rule): pehle yaha FASHION demo lists
    // (Pink Hoodie / Denim Jacket / kids clothes) preload hoti thin — API
    // fail hone par user ko kapdon ka fake data dikhta tha. Ab sab khaali
    // start hota hai; sirf REAL alfurqan.ae api data bharta hai. Khaali
    // rehne par views section hide kar dete hain (guards laga diye hai).
    dealOfTheDayList = [];
    findStyleCategory = [];
    findStyleCategoryList = [];
    biggestDealBrandList = [];
    homeKidsCornerList = [];
    offerCornerList = [];
    loginWidth = ScreenUtil().screenWidth;
    loginHeight = 500.w;
    update();
    // try/catch — koi bhi api fail ho jaye to bhi shimmer hamesha band ho
    // aur baaki sections load ho jaye (ek ki failure dusre ko na roke).
    //
    // STEP 1: NAYA home api (GetHomePageDataApp) — banners + categories +
    // deals + find-your-match tabs + trending sab isi ek call me aata hai.
    try {
      await fetchHomePageData();
    } catch (_) {}

    // STEP 2 (fallback): naya home api fail ho jaye to purane tareeke se
    // categories/products lao.
    if (apiCategoryList.isEmpty) {
      try {
        await fetchTopCategories();
      } catch (_) {}
    }
    if (!homeApiLoaded) {
      try {
        await fetchHomeProducts();
      } catch (_) {}
    }

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

  /// NAYA home api (GetHomePageDataApp) — purana GetTopCategory backend ne
  /// band kar diya hai (404), ab home page ka SAARA data isi ek call se aata
  /// hai: banners (redirect links ke sath) + top categories + deals +
  /// trending + find-your-match tabs.
  Future<void> fetchHomePageData() async {
    final res = await ApiService().request<HomePageDataModel>(
      endpoint: ApiEndpoints.homePageData,
      method: ApiMethod.get,
      fromJson: (json) => HomePageDataModel.fromJson(
          json is Map<String, dynamic> ? json : Map<String, dynamic>.from(json as Map)),
    );

    if (!res.isSuccess || res.data == null) return;
    final d = res.data!;

    // --- categories row (+ CategoryCache, taaki shop/search/category tab bhi chale) ---
    if (d.topCategories.isNotEmpty) {
      apiCategoryList =
          d.topCategories.map((e) => e.toCategoryApiModel()).toList();
      CategoryCache.items = List.of(apiCategoryList);
      homeCategoryList =
          apiCategoryList.map((e) => e.toHomeCategoryModel()).toList();
    }

    // --- banner carousel (redirect links ke sath: product/category/external) ---
    if (d.banners.isNotEmpty) {
      bannerList = d.banners.map((e) => e.toHomeBannerModel()).toList();
    }

    // --- Deals of the Day (real api section) ---
    if (d.deals.isNotEmpty) {
      dealOfTheDayList = d.deals.map((e) => e.toDealModel()).toList();
      for (final p in d.deals) {
        _addUnique(homeApiProductsAll, p.toApiModel());
      }
    }

    // --- Find your Style chips <- Find_Your_Match tabs ---
    if (d.matchTabs.isNotEmpty) {
      matchTabs = d.matchTabs;
      findStyleCategory = d.matchTabs
          .asMap()
          .entries
          .map((e) => {'id': e.key, 'title': e.value.title})
          .toList();
      for (final tab in d.matchTabs) {
        for (final p in tab.products) {
          _addUnique(homeApiProductsAll, p.toApiModel());
        }
      }
    }

    // --- Section titles/descriptions (api se; khaali ho to view apni
    // translated fallback text dikhayega) ---
    dealsTitle = d.dealsTitle;
    dealsDescription = d.dealsDescription;
    trendingTitle = d.trendingTitle;
    trendingDescription = d.trendingDescription;
    matchSectionTitle = d.matchTitle;
    matchSectionDescription = d.matchDescription;

    // --- Offer banners: pehla non-empty = bada banner, baaki = offer-corner grid ---
    final usableOffers =
        d.offerBanners.where((b) => b.image.isNotEmpty).toList();
    if (usableOffers.isNotEmpty) {
      mainOfferBanner = usableOffers.first;
      offerCornerBanners = usableOffers.length > 1
          ? usableOffers.sublist(1)
          : <HomePageBanner>[];
    }

    // --- Brands (sirf jab backend Status=true kare; abhi false hai to khaali) ---
    brandList = d.brandStatus ? d.brands : <HomePageBrand>[];

    // --- Kids corner / New Arrivals <- Tranding_Products ---
    if (d.trending.isNotEmpty) {
      homeKidsCornerList =
          d.trending.map((e) => e.toFindStyleModel()).toList();
      for (final p in d.trending) {
        _addUnique(homeApiProductsAll, p.toApiModel());
      }
    }

    // home api se products/categories mile to "loaded" maano (fallback skip hoga)
    if (d.deals.isNotEmpty ||
        d.trending.isNotEmpty ||
        d.matchTabs.isNotEmpty ||
        d.topCategories.isNotEmpty) {
      homeApiLoaded = true;
    }
    syncFavStatesFromWishlist();
    update();
  }

  /// Sab home lists ke heart icons ko SACH (saved wishlist storage) ke hisaab
  /// se set karo. Iske bina hearts purani in-memory state dikhate the —
  /// user ko lagta item wishlist me hai, jabki wahan nahi tha (confusion).
  /// Wishlist me har add/remove par bhi ye call hoti hai (_notifyUi se).
  void syncFavStatesFromWishlist() {
    final ids =
        WishlistController.loadWishlistItems().map((e) => e.id).toSet();
    for (final item in dealOfTheDayList) {
      item.isFav = ids.contains(item.id);
    }
    for (final item in findStyleCategoryList) {
      item.isFav = ids.contains(item.id);
    }
    for (final item in findStyleCategoryCategoryWiseList) {
      item.isFav = ids.contains(item.id);
    }
    for (final item in homeKidsCornerList) {
      item.isFav = ids.contains(item.id);
    }
    update();
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
    // Mobile network kabhi-kabhi flaky hota hai — fail hone par ek baar
    // aur koshish karo (isliye 2 attempts ka chhota loop).
    ApiResponse<ProductListResponseModel>? res;
    for (var attempt = 0; attempt < 2; attempt++) {
      res = await ApiService().request<ProductListResponseModel>(
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
        break;
      }
      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }

    if (res != null &&
        res!.isSuccess &&
        res!.data != null &&
        res!.data!.data.isNotEmpty) {
      newestApiProducts = res!.data!.data;

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
    syncFavStatesFromWishlist();
    update();
  }

  /// Home ke kisi bhi product card (deals/find-style/kids) ka tap —
  /// id se real ProductApiModel dhoond kar detail page pe le jao
  /// (na mile to purana demo detail fallback khulega).
  openProductById(int id) {
    ProductApiModel? found;
    // pehle naye home api ke products me dhoondo (deals/tabs/trending),
    // phir newest list me — dono cover ho jaye.
    for (final p in homeApiProductsAll) {
      if (p.id == id) {
        found = p;
        break;
      }
    }
    if (found == null) {
      for (final p in newestApiProducts) {
        if (p.id == id) {
          found = p;
          break;
        }
      }
    }
    appCtrl.goToProductDetail(arguments: found);
  }

  /// Offer banner tap — Redirect_Link ke hisaab se route karo:
  /// product -> usi product ka detail, collection -> us category ka shop page,
  /// external_url -> kuch mat kholo (app ke bahar ka link).
  openOfferBanner(HomePageBanner? banner) {
    if (banner == null) return;
    if (banner.linkType == 'product' && banner.productId != null) {
      openProductById(banner.productId!);
      return;
    }
    if (banner.linkType == 'external_url') return;
    if (banner.categorySlug != null && banner.categorySlug!.isNotEmpty) {
      goToCategoryProducts(banner.categorySlug);
      return;
    }
    goToShopAll();
  }

  /// Saare products wala shop page kholo.
  goToShopAll() {
    appCtrl.isSearch = false;
    appCtrl.selectedIndex = 1;
    appCtrl.update();
    Get.toNamed(routeName.shopPage, arguments: "All");
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
    // slug filter ke liye + name TITLE ke liye (title me slug mat dikhao)
    final catName = CategoryCache.resolve(slug)?.name ?? slug;
    Get.toNamed(routeName.shopPage,
        arguments: {'slug': slug, 'name': catName});
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
          // mrp = selling price (bold), totalPrice = original (struck)
          entry = HomeDealOfTheDayModel(
            id: item.id,
            name: item.name,
            image: item.image,
            byWhom: 'مكتبة الفرقان',
            discount: item.discount,
            isFav: newVal,
            mrp: item.mrp,
            totalPrice: item.totalPrice,
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
          mrp: data.mrp, // selling (bold)
          totalPrice: data.totalPrice, // original (struck)
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
    // NAYA home api: chips = Find_Your_Match tabs — tap par usi tab ke
    // products dikhao (chip ka 'id' = tab index).
    if (matchTabs.isNotEmpty && index is int && index < matchTabs.length) {
      findStyleCategoryCategoryWiseList =
          matchTabs[index].products.map((e) => e.toFindStyleModel()).toList();
    }
    // fallback: purane tareeke se categoryId se filter (jab home api na ho)
    if (findStyleCategoryCategoryWiseList.isEmpty) {
      for (var i = 0; i < findStyleCategoryList.length; i++) {
        if (categoryId.toString() ==
            findStyleCategoryList[i].categoryId.toString()) {
          findStyleCategoryCategoryWiseList.add(findStyleCategoryList[i]);
        }
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
