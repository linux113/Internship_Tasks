import '../../../config.dart';

/// CATEGORY TAB — REDESIGN.
/// Pehle: odd/even staggered colored text boxes — user feedback: "bilkul
/// ugly lag raha hai". Ab clean MODERN GRID: har category ka rounded image
/// card + niche naam, 3 columns, sab REAL api data (GetHomePageDataApp ke
/// Top Categories). Tap → us category ke products (slug + naam ke sath
/// shop page).
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({Key? key}) : super(key: key);

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final categoryCtrl = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CategoryController>(builder: (_) {
      final appCtrl = categoryCtrl.appCtrl;
      return Directionality(
        textDirection:
            appCtrl.isRTL || appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
          backgroundColor: appCtrl.appTheme.whiteColor,
          body: appCtrl.isShimmer
              ? const CategoryShimmer()
              // 10/09 user ask: pull-to-refresh = categories FRESH (cache
              // bypass). Empty state par bhi pull kaam kare (ListView wrap).
              : RefreshIndicator(
                  color: const Color(0xFF044015),
                  onRefresh: () async => categoryCtrl.getData(force: true),
                  child: categoryCtrl.categoryList.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: AppScreenUtil().screenHeight(200),
                            ),
                            Center(
                              child: LatoFontStyle(
                                  text: "Categories load nahi hui",
                                  color: appCtrl.appTheme.contentColor,
                                  fontSize: FontSizes.f14),
                            )
                          ],
                        )
                      : GridView.builder(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppScreenUtil().screenWidth(15),
                          vertical: AppScreenUtil().screenHeight(15)),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: AppScreenUtil().screenWidth(12),
                        mainAxisSpacing: AppScreenUtil().screenHeight(16),
                      ),
                      itemCount: categoryCtrl.categoryList.length,
                      itemBuilder: (context, index) {
                        final cat = categoryCtrl.categoryList[index];
                        return GestureDetector(
                          onTap: () => categoryCtrl.goToCategoryProducts(cat),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // 22/09 (Lalit — "category page ke CIRCLE apne
                              // SQUARE frame ke BAHAR nikle hue hai"): pehle
                              // image SQUARE card ko poori bharti thi.
                              // 21/09 (Lalit v1685 — "category me image HALF
                              // CUTTING aa rahi hai"): ClipOval ko Expanded ka
                              // RECT (width×lambe-portrait-height) mil raha
                              // tha — ClipOval RECT bounds par ELLIPSE karta
                              // hai, aur cover-scale gol coin art ki upar/
                              // neeche ki patti elliptical clip se KAT JATA
                              // (screenshot me har coin adhura kata dikhta).
                              // ROOT-FIX: hamesha TRUE SQUARE (AspectRatio 1,
                              // Center se center) ke andar ClipOval — square
                              // par oval == poora CIRCLE, coin hamesha poora,
                              // white rounded frame charo taraf barabar marg
                              // (outer hardEdge clipping ab bhi raksha rakhta
                              // hai aur server ke square-art par cover ==
                              // contain, koi double-crop ka effect NAHI).
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      EdgeInsets.all(AppScreenUtil().size(12)),
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: appCtrl.appTheme.whiteColor,
                                    borderRadius: BorderRadius.circular(
                                        AppScreenUtil().borderRadius(12)),
                                    border: Border.all(
                                        color: appCtrl.appTheme.greyLight25),
                                  ),
                                  child: Center(
                                    child: AspectRatio(
                                      aspectRatio: 1.0,
                                      child: ClipOval(
                                        child: imageNetwork(
                                            url: cat.displayImageUrl ?? '',
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Space(0, 8),
                              // ---- category name ----
                              LatoFontStyle(
                                  text: cat.name ?? '',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: FontSizes.f12,
                                  fontWeight: FontWeight.w600,
                                  color: appCtrl.appTheme.blackColor),
                            ],
                          ),
                        );
                      },
                    ),
        ),
        ),
      );
    });
  }
}
