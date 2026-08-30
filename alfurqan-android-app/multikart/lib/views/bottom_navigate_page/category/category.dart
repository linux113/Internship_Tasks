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
              : categoryCtrl.categoryList.isEmpty
                  ? Center(
                      child: LatoFontStyle(
                          text: "Categories load nahi hui",
                          color: appCtrl.appTheme.contentColor,
                          fontSize: FontSizes.f14),
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
                              // ---- rounded image card ----
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: appCtrl.appTheme.greyLight25,
                                    borderRadius: BorderRadius.circular(
                                        AppScreenUtil().borderRadius(12)),
                                    border: Border.all(
                                        color: appCtrl.appTheme.greyLight25),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(
                                        AppScreenUtil().borderRadius(12)),
                                    child: imageNetwork(
                                        url: cat.displayImageUrl ?? '',
                                        fit: BoxFit.cover),
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
      );
    });
  }
}
