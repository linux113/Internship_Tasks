import '../../config.dart';
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
    update();
    if (Get.isRegistered<ShopController>()) {
      final shop = Get.find<ShopController>();
      shop.priceRange = "";
      shop.rating = "";
      shop.attribute = "";
      shop.sortField = ""; // Recommended = natural order
      shop.sortDirection = "asc";
      shop.applyClientFilters();
    }
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
      update();
    }
    colorList = AppArray().colorList;

    update();
    super.onReady();
  }
}
