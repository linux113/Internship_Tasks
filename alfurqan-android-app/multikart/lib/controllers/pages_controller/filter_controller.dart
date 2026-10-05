import '../../config.dart';
import '../../services/category_cache.dart';
import 'shop_controller.dart';

class FilterController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  /// Fallback price range — catalog load na hui ho tab (dynamic max
  /// ShopController.catalogMaxPrice se aata hai — 08/09: slider ki range
  /// ab SACH me visible products ke prices ke hisaab se hai).
  static const double maxPrice = 300;
  double maxPriceVal = maxPrice;
  RangeValues currentRangeValues = const RangeValues(0, maxPrice);

  // Purane fashion-template filter state (Brand/Size/Occasion/Color) — ab
  // UI me nahi dikhate (book store ke liye bematlab the); yeh fields sirf
  // purani unused layout files ke compile-ke liye rakhe hai.
  List brandFilterList = [];
  List occasionFilterList = [];
  List sizeList = [];
  List colorList = [];
  // NOTE: internal sort VALUE kabhi translate nahi hota (DropdownButton ka
  // value HAMESHA items me se ek hona chahiye — warna crash). Sirf dikhne
  // wala TEXT translate hota hai (SortByDropDown me). Pehle yaha value par
  // translation laga tha — language change par crash risk tha.
  String dropDownVal = "Recommended";
  int selectedBrand = 0;
  int selectedOccasion = 0;
  int selectedColor = 0;
  int selectSize = 0;

  // ---------------- 21/09 MULTI-FILTER (Lalit point 1) ----------------
  /// Selected CATEGORY slugs (multi-select chips). Khaali = no category
  /// filter. Real categories CategoryCache se aati hai.
  final List<String> selectedCategorySlugs = <String>[];

  /// Minimum rating filter (0 = without-filter; 1..4 = "N+ stars").
  double ratingMin = 0;

  // ---------------- 03/10 Flipkart-style layout (Lalit screenshot) ----------------
  /// Left list ka SELECTED section ('sort' | 'discount' | 'categories' |
  /// 'price' | 'rating'). Discount sirf tab dikhta hai jab catalog me
  /// sach me koi discounted product ho.
  String selectedSectionId = 'sort';

  /// Min DISCOUNT % (0 = filter nahi) — REAL sale vs price se.
  double discountMin = 0;

  /// Bottom button ka LIVE count ("See N products") — 05/10 FIX (Lalit
  /// screenshots me page khulte hi "See 0 products" atka tha): pehle ye
  /// VARIABLE tha jo sirf selection-change par update hota tha — page
  /// reopen/timing par purana value dikhta tha. Ab GETTER hai: jab bhi UI
  /// rebuild ho (koi bhi change), shop ke ASLI engine se FRESH count.
  int get previewCount {
    if (!Get.isRegistered<ShopController>()) return 0;
    final shop = Get.find<ShopController>();
    final pr = (currentRangeValues.start <= 0 &&
            currentRangeValues.end >= maxPriceVal)
        ? ''
        : '${currentRangeValues.start.toInt()},${currentRangeValues.end.toInt()}';
    return shop.countFor(
        priceR: pr,
        catSlugs: selectedCategorySlugs,
        ratingMn: ratingMin,
        discMn: discountMin);
  }

  void selectSection(String id) {
    selectedSectionId = id;
    update();
  }

  /// Catalog me koi discounted product hai? Discount section DATA-DRIVEN
  /// — koi discount nahi to section hi nahi dikhta (fake option kabhi
  /// nahi).
  bool get hasAnyDiscount {
    if (!Get.isRegistered<ShopController>()) return false;
    return Get.find<ShopController>()
        .fullProducts
        .any((p) => p.discountPct > 0);
  }

  /// Har selection change par — UI dobara banao (count GETTER apne aap
  /// fresh ho jata hai).
  void onFiltersChanged() {
    update();
  }

  void setDiscountMin(double v) {
    discountMin = discountMin == v ? 0 : v; // dobara tap = clear
    onFiltersChanged();
  }

  void setSort(String v) {
    dropDownVal = v; // internal value — translate NAHI karna
    onFiltersChanged();
  }

  void setPriceRange(RangeValues v) {
    currentRangeValues = v;
    onFiltersChanged();
  }

  void toggleCategory(String slug) {
    if (selectedCategorySlugs.contains(slug)) {
      selectedCategorySlugs.remove(slug);
    } else {
      selectedCategorySlugs.add(slug);
    }
    onFiltersChanged();
  }

  void setRatingMin(double v) {
    ratingMin = ratingMin == v ? 0 : v; // dobara tap = clear
    onFiltersChanged();
  }
  var data = [
    {"val": "0.0"},
    {"val": "50.0"},
    {"val": "100.0"},
    {"val": "150.0"},
    {"val": "200.0"},
    {"val": "250.0"},
    {"val": "300.0"}
  ];

  //select brand (unused UI ke liye)
  selectBrandFunction(index) {
    selectedBrand = index;
    update();
  }

  //select occasion (unused UI ke liye)
  selectOccasionFunction(index) {
    selectedOccasion = index;
    update();
  }

  /// APPLY — pehle YE BUTTON KUCH NAHI KARTA THA (sirf Get.back)!! Ab REAL:
  /// sort + price range ShopController me set karke list apply hoti hai.
  /// 08/09: full REFETCH ki jagah client-side reapply (already-loaded
  /// catalog par) — apply TURANT hota hai, spinner flash nahi.
  void applyToShop() {
    if (Get.isRegistered<ShopController>()) {
      final shop = Get.find<ShopController>();

      // price filter (poori range select = koi price filter nahi)
      if (currentRangeValues.start <= 0 &&
          currentRangeValues.end >= maxPriceVal) {
        shop.priceRange = "";
      } else {
        shop.priceRange =
            "${currentRangeValues.start.toInt()},${currentRangeValues.end.toInt()}";
      }

      // 21/09 multi-filter — CATEGORY (multi) + RATING (min) shop par set
      shop.filterCategorySlugs
        ..clear()
        ..addAll(selectedCategorySlugs);
      shop.ratingMin = ratingMin;
      // 03/10 — DISCOUNT (min %) bhi
      shop.discountMin = discountMin;

      // sort mapping — backend ke sort params IGNORE hote hain (live
      // verify), isliye ShopController ye CLIENT-SIDE apply karta hai:
      //   Recommended   = "" (backend ka natural order — naye pehle)
      //   What's New    = created_at desc
      //   Price         = price asc/desc (REAL finalPrice = sale ya price)
      switch (dropDownVal) {
        case "Price: Low to High":
          shop.sortField = "price";
          shop.sortDirection = "asc";
          break;
        case "Price: High to Low":
          shop.sortField = "price";
          shop.sortDirection = "desc";
          break;
        case "What's New":
          shop.sortField = "created_at";
          shop.sortDirection = "desc";
          break;
        default: // Recommended
          shop.sortField = "";
          shop.sortDirection = "asc";
      }
      shop.applyClientFilters();
    }
    Get.back();
  }

  //reset — selections + shop ke applied filters dono clear karke fresh list
  resetFilter() {
    dropDownVal = "Recommended"; // internal value — translate NAHI karna
    selectedBrand = 0;
    selectedOccasion = 0;
    selectedColor = 0;
    selectSize = 0;
    currentRangeValues = RangeValues(0, maxPriceVal);
    selectedCategorySlugs.clear();
    ratingMin = 0;
    discountMin = 0;
    if (Get.isRegistered<ShopController>()) {
      final shop = Get.find<ShopController>();
      shop.priceRange = "";
      shop.rating = "";
      shop.attribute = "";
      shop.filterCategorySlugs.clear();
      shop.ratingMin = 0;
      shop.discountMin = 0;
      shop.sortField = ""; // Recommended = natural order
      shop.sortDirection = "asc";
      shop.applyClientFilters();
    }
    // 03/10: shop.applyClientFilters ke baad UI refresh — button apna
    // fresh count getter se le lega (poora count).
    update();
  }

  @override
  void onReady() {
    // TODO: implement onReady
    brandFilterList = AppArray().brandFilterList;
    sizeList = AppArray().sizeList;
    occasionFilterList = AppArray().occasionFilterList;
    // 08/09: (1) slider ki MAX price visible catalog ke REAL prices se
    // (25 wali books ke liye 300 ka slider bekaar tha — pura range ek
    // chhote se hisse me simat jata); (2) shop me ALREADY-APPLIED filter
    // dobara dikhna chahiye (har baar page reopen par "All" reset dikhna
    // jhooth-lagta hai jabki list filtered hai).
    if (Get.isRegistered<ShopController>()) {
      final shop = Get.find<ShopController>();
      maxPriceVal = shop.catalogMaxPrice;
      if (shop.sortField == "price") {
        dropDownVal = shop.sortDirection == "desc"
            ? "Price: High to Low"
            : "Price: Low to High";
      } else if (shop.sortField == "created_at") {
        dropDownVal = "What's New";
      } else {
        dropDownVal = "Recommended";
      }
      if (shop.priceRange.isNotEmpty) {
        final parts = shop.priceRange.split(',');
        final lo = double.tryParse(parts[0].trim()) ?? 0;
        final hi = parts.length > 1
            ? (double.tryParse(parts[1].trim()) ?? maxPriceVal)
            : maxPriceVal;
        currentRangeValues = RangeValues(
            lo.clamp(0, maxPriceVal), hi.clamp(0, maxPriceVal));
      } else {
        currentRangeValues = RangeValues(0, maxPriceVal);
      }
      // 21/09 multi-filter re-hydrate: already-applied category chips +
      // rating chips dobara dikhne chahiye (jhootha "sab reset" nahi)
      selectedCategorySlugs
        ..clear()
        ..addAll(shop.filterCategorySlugs);
      ratingMin = shop.ratingMin;
      discountMin = shop.discountMin; // 03/10 discount bhi re-hydrate
      update();
    }
    update();
    colorList = AppArray().colorList;
    // Category chips ke liye REAL categories — cache ensure (async, baad
    // me loaded hone par bhi chips update ho jaye)
    CategoryCache.ensureLoaded().then((_) => update());

    update();
    super.onReady();
  }
}
