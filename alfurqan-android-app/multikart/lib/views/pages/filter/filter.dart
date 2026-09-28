import '../../../config.dart';
import '../../../services/category_cache.dart';

class Filter extends StatelessWidget {
  final filterCtrl = Get.put(FilterController());

  Filter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (_) {
      return Directionality(
        textDirection:
            filterCtrl.appCtrl.isRTL || filterCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
            appBar: AppBar(
                elevation: 0,
                title: Text(FilterFont().filters),
                backgroundColor: Colors.white,
                automaticallyImplyLeading: false,
                actions: const [CloseSquareIcon()]),
            body: Stack(alignment: Alignment.bottomCenter, children: [
              SingleChildScrollView(
                  // Issue #5 (10/09): RESET/APPLY buttons content ke UPAR
                  // float karte hai (Stack) — price ke LIVE value boxes
                  // slider ghumate waqt unke neeche chhup jaate the
                  // ("price container is overlapped by the buttons"). Ab
                  // scroll content ke end me buttons-jitni empty space hai,
                  // isliye koi bhi cheez unke neeche nahi chhupti.
                  padding: EdgeInsets.only(
                      bottom: AppScreenUtil().screenHeight(110)),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    FilterWidget().titleText(FilterFont().shortBy),
                    const Space(0, 20),

                    //short by layout
                    const SortByLayout(),

                    // FIX (user report — strict): yaha STATIC fashion filters
                    // the — Brand (Zara/Mast & harbour/gucci), Size (S/M/L/
                    // XL), Occasion (Casual/Sports/Party), Colors. Book store
                    // ke liye sab bematlab + fake data tha, isliye remove.
                    // 21/09 (Lalit point 1 — MULTI-FILTER): ab REAL options —
                    // CATEGORY multi-select chips (server ke asli categories)
                    // + min-RATING chips — dono ke saath Sort + Price.

                    // ---- CATEGORY (multi-select) ----
                    const Space(0, 10),
                    FilterWidget().titleText("categories".tr),
                    const Space(0, 12),
                    _CategoryChips(),
                    // ---- min-RATING (stars) ----
                    const Space(0, 10),
                    FilterWidget().titleText(FilterFont().customerRating),
                    const Space(0, 12),
                    _RatingChips(),
                    const Space(0, 10),

                    FilterWidget().titleText(FilterFont().price),

                    const Space(0, 20),
                    //range slider
                    const RangeValueLayout(),
                    const CustomRangeSlider(),
                    const Space(0, 20)
                  ]).marginSymmetric(
                      horizontal: AppScreenUtil().screenWidth(15))),
              BottomLayout(
                  firstButtonText: FilterFont().reset,
                  secondButtonText: FilterFont().applyFilter,firstTap: ()=>filterCtrl.resetFilter(),
                  // FIX: pehle APPLY sirf sheet band karta tha — kuch apply
                  // hi nahi hota tha! Ab sort+price + category(multi) +
                  // rating(min) REAL apply callback hota hai.
                  secondTap: ()=>filterCtrl.applyToShop())
            ])),
      );
    });
  }
}

// ---------------- 21/09 MULTI-FILTER widgets (Lalit point 1) ----------------

/// REAL categories (CategoryCache — GetHomePageDataApp se) multi-select
/// chips; ko category load na hui ho to section khaali/blank nahi (sirf
/// fetch pending ho to kuch select nahi, APPLY par phir bhi kaam karta hai).
class _CategoryChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.isRegistered<AppController>()
        ? Get.find<AppController>()
        : Get.put(AppController());
    return GetBuilder<FilterController>(builder: (c) {
      final cats = CategoryCache.items;
      if (cats.isEmpty) {
        return Text(
          CategoryCache.items.isEmpty ? '' : 'pleaseWait'.tr,
          style: TextStyle(color: appCtrl.appTheme.contentColor),
        );
      }
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final cat in cats)
            if ((cat.slug ?? '').isNotEmpty || (cat.name ?? '').isNotEmpty)
              GestureDetector(
                onTap: () => c.toggleCategory(cat.slug ?? cat.name ?? ''),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: c.selectedCategorySlugs
                            .contains(cat.slug ?? cat.name ?? '')
                        ? appCtrl.appTheme.primary.withOpacity(.12)
                        : appCtrl.appTheme.whiteColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: c.selectedCategorySlugs
                              .contains(cat.slug ?? cat.name ?? '')
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.greyLight25,
                    ),
                  ),
                  child: Text(
                    cat.name ?? cat.slug ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.selectedCategorySlugs
                              .contains(cat.slug ?? cat.name ?? '')
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.blackColor,
                    ),
                  ),
                ),
              ),
        ],
      );
    });
  }
}

/// min-RATING chips — 4★+, 3★+, 2★+, 1★+ (ek tap select, dobara tap clear).
class _RatingChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appCtrl = Get.isRegistered<AppController>()
        ? Get.find<AppController>()
        : Get.put(AppController());
    return GetBuilder<FilterController>(builder: (c) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final stars in const [4.0, 3.0, 2.0, 1.0])
            GestureDetector(
              onTap: () => c.setRatingMin(stars),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: c.ratingMin == stars
                      ? appCtrl.appTheme.primary.withOpacity(.12)
                      : appCtrl.appTheme.whiteColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: c.ratingMin == stars
                        ? appCtrl.appTheme.primary
                        : appCtrl.appTheme.greyLight25,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.star_rounded,
                      size: 16,
                      color: c.ratingMin == stars
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.contentColor),
                  const SizedBox(width: 4),
                  Text(
                    '${stars.toInt()}+',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.ratingMin == stars
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.blackColor,
                    ),
                  ),
                ]),
              ),
            ),
        ],
      );
    });
  }
}
