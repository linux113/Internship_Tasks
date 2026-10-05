import '../../../config.dart';
import '../../../services/category_cache.dart';

/// FILTERS — 03/10 (Lalit ka Flipkart screenshot): LEFT side filter ke
/// SECTIONS (Sort / Discount / Categories / Price / Customer Rating),
/// RIGHT side us section ke REAL options (checkbox/radio), upar CLEAR
/// ALL FILTERS, neeche green "See N products" button — N LIVE count
/// (selections badalte hi update). Sirf REAL data wale sections dikhte
/// hai (Discount tab hi jab catalog me sach me discounted product ho).
class Filter extends StatelessWidget {
  final filterCtrl = Get.put(FilterController());

  Filter({Key? key}) : super(key: key);

  static const Color _green = Color(0xFF044015);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (c) {
      final appCtrl = c.appCtrl;
      // Sections ka ORDER Flipkart jaisa: Sort -> Discount (data-driven)
      // -> Categories -> Price -> Customer Rating.
      final sections = <MapEntry<String, String>>[
        MapEntry('sort', FilterFont().shortBy),
        if (c.hasAnyDiscount) MapEntry('discount', 'discount'.tr),
        MapEntry('categories', 'categories'.tr),
        MapEntry('price', FilterFont().price),
        MapEntry('rating', FilterFont().customerRating),
      ];
      final selId =
          sections.any((s) => s.key == c.selectedSectionId)
              ? c.selectedSectionId
              : 'sort';
      return Directionality(
        textDirection:
            appCtrl.isRTL || appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          appBar: AppBar(
            elevation: 0.5,
            backgroundColor: appCtrl.appTheme.whiteColor,
            leading: InkWell(
              onTap: () => Get.back(),
              child: Icon(Icons.arrow_back_rounded,
                  color: appCtrl.appTheme.blackColor),
            ),
            title: Text(FilterFont().filters,
                style: TextStyle(
                    color: appCtrl.appTheme.blackColor,
                    fontWeight: FontWeight.w600)),
            actions: [
              TextButton(
                onPressed: () => c.resetFilter(),
                child: Text('clearAllFilters'.tr,
                    style: const TextStyle(
                        color: _green, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- LEFT: sections list (Flipkart style) --------
              Container(
                width: AppScreenUtil().screenWidth(118),
                color: appCtrl.appTheme.greyLight25.withOpacity(.25),
                child: ListView(
                  children: [
                    for (final s in sections)
                      InkWell(
                        onTap: () => c.selectSection(s.key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selId == s.key
                                ? appCtrl.appTheme.whiteColor
                                : Colors.transparent,
                            // RTL (Arabic) me green strip START side hi
                            // rahe — BorderDirectional se.
                            border: BorderDirectional(
                              start: BorderSide(
                                color: selId == s.key
                                    ? _green
                                    : Colors.transparent,
                                width: 3,
                              ),
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: AppScreenUtil().screenWidth(12),
                              vertical: AppScreenUtil().screenHeight(15)),
                          child: Text(
                            s.value,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selId == s.key
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: selId == s.key
                                  ? _green
                                  : appCtrl.appTheme.blackColor,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // -------- RIGHT: selected section ke options --------
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppScreenUtil().screenWidth(14),
                      vertical: AppScreenUtil().screenHeight(10)),
                  child: _buildSectionOptions(c, selId),
                ),
              ),
            ],
          ),
          // -------- BOTTOM: "See N products" — LIVE real count --------
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15, 8, 15, 10),
              child: SizedBox(
                height: 48,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => c.applyToShop(),
                  child: Text(
                    'seeProducts'
                        .trParams({'count': '${c.previewCount}'}),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  /// Right pane — selected section ke REAL options.
  Widget _buildSectionOptions(FilterController c, String selId) {
    switch (selId) {
      case 'sort':
        // Sirf wohi sort options jinke liye backend ka real field hai
        // (created_at / price) — fake option nahi.
        final opts = <MapEntry<String, String>>[
          MapEntry('Recommended', FilterFont().recommended),
          MapEntry("What's New", FilterFont().whatsNew),
          MapEntry('Price: Low to High', FilterFont().lowToHigh),
          MapEntry('Price: High to Low', FilterFont().highToLow),
        ];
        return Column(children: [
          for (final o in opts)
            _optionRow(
              c,
              label: o.value,
              selected: c.dropDownVal == o.key,
              single: true,
              onTap: () => c.setSort(o.key),
            ),
        ]);
      case 'discount':
        // REAL discount % (sale_price vs price) — Flipkart ke "% or more"
        // style, single-select (dobar tap = clear).
        return Column(children: [
          for (final d in const [10.0, 20.0, 30.0, 40.0, 50.0])
            _optionRow(
              c,
              label: 'percentOrMore'
                  .trParams({'percent': '${d.toInt()}'}),
              selected: c.discountMin == d,
              single: true,
              onTap: () => c.setDiscountMin(d),
            ),
        ]);
      case 'categories':
        // REAL categories (CategoryCache — GetHomePageDataApp se),
        // MULTI-select checkboxes.
        final cats = CategoryCache.items;
        if (cats.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text('pleaseWait'.tr,
                style: TextStyle(color: c.appCtrl.appTheme.contentColor)),
          );
        }
        return Column(children: [
          for (final cat in cats)
            if ((cat.slug ?? '').isNotEmpty || (cat.name ?? '').isNotEmpty)
              _optionRow(
                c,
                label: cat.name ?? cat.slug ?? '',
                selected: c.selectedCategorySlugs
                    .contains(cat.slug ?? cat.name ?? ''),
                single: false,
                onTap: () => c.toggleCategory(cat.slug ?? cat.name ?? ''),
              ),
        ]);
      case 'price':
        // LIVE value boxes + dynamic-range slider (catalog ki real max
        // price se) — selection hote hi preview count update.
        return Column(children: [
          const RangeValueLayout(),
          const CustomRangeSlider(),
        ]);
      case 'rating':
        // REAL avg rating (rating_count/review_ratings) — "4★ & above"
        // single-select (dobar tap = clear).
        return Column(children: [
          for (final stars in const [4.0, 3.0, 2.0, 1.0])
            _optionRow(
              c,
              label: 'starsAndAbove'
                  .trParams({'stars': '${stars.toInt()}'}),
              selected: c.ratingMin == stars,
              single: true,
              onTap: () => c.setRatingMin(stars),
            ),
        ]);
      default:
        return const SizedBox();
    }
  }

  /// Ek option row — multi-select (square checkbox) ya single-select
  /// (round radio); Flipkart jaisa: tick green, row tap-pure.
  Widget _optionRow(FilterController c,
      {required String label,
      required bool selected,
      required bool single,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: AppScreenUtil().screenHeight(9)),
        child: Row(children: [
          Icon(
            selected
                ? (single
                    ? Icons.radio_button_checked
                    : Icons.check_box_rounded)
                : (single
                    ? Icons.radio_button_off
                    : Icons.check_box_outline_blank_rounded),
            size: 20,
            color: selected
                ? _green
                : c.appCtrl.appTheme.contentColor.withOpacity(.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? _green
                    : c.appCtrl.appTheme.blackColor,
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
