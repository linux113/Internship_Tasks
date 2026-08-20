import '../../config.dart';
import '../../services/category_cache.dart';

/// "Trending Category" horizontal list.
/// FIX: pehle yaha fashion demo tiles (Womens Wear / Kurtas etc) aati thi,
/// aur tap karne par shop page unhi naam se khaali khulta tha. Ab yaha
/// alfurqan.ae ki REAL top categories dikhti hai aur tap se sahi slug ke
/// sath us category ka shop page khulta hai.
class CommonTrendingCategory extends StatefulWidget {
  final dynamic data;
  final GestureTapCallback? onTap;

  const CommonTrendingCategory({Key? key, this.data, this.onTap})
      : super(key: key);

  @override
  State<CommonTrendingCategory> createState() => _CommonTrendingCategoryState();
}

class _CommonTrendingCategoryState extends State<CommonTrendingCategory> {
  @override
  void initState() {
    super.initState();
    CategoryCache.ensureLoaded().then((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      // Api se categories aa gayi to real list, warna khaali jagah (koi
      // fashion demo tiles nahi dikhayenge).
      final categories = CategoryCache.items;
      if (categories.isEmpty) {
        return SizedBox(height: AppScreenUtil().screenHeight(10));
      }

      return Container(
        padding:
            EdgeInsets.symmetric(horizontal: AppScreenUtil().screenWidth(15)),
        height: AppScreenUtil().screenHeight(160),
        child: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: categories.length,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final category = categories[index];
            return InkWell(
              onTap: widget.onTap ??
                  () => appCtrl.goToShopPage(category.slug ?? ''),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppScreenUtil().borderRadius(6)),
                    child: FadeInImageLayout(
                      image: category.displayImageUrl,
                      fit: BoxFit.cover,
                      height: AppScreenUtil().screenHeight(105),
                      width: AppScreenUtil().screenWidth(110),
                    ),
                  ),
                  const Space(0, 8),
                  SizedBox(
                    width: AppScreenUtil().screenWidth(110),
                    child: LatoFontStyle(
                      text: category.name ?? '',
                      fontSize: FontSizes.f12,
                      fontWeight: FontWeight.w500,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      color: appCtrl.appTheme.blackColor,
                    ),
                  ),
                ],
              ),
            ).marginOnly(right: AppScreenUtil().screenWidth(10));
          },
        ),
      );
    });
  }
}
