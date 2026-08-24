import '../../../../../config.dart';

/// Brands section.
/// FIX: pehle yaha 100% DEMO brand logos (NORTH2.0 / treva / velocity9)
/// asset images se aate the. Ab sirf tab dikhta hai jab backend
/// Brand.Status=true kare aur real brand list bheje — warna poora section
/// hide rehta hai.
class DealsBrands extends StatelessWidget {
  const DealsBrands({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      final brands = homeCtrl.brandList;
      if (brands.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
                  text: HomeFont().biggestDeal,
                  fontSize: FontSizes.f16,
                  fontWeight: FontWeight.normal,
                  color: homeCtrl.appCtrl.appTheme.blackColor)
              .marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: brands.asMap().entries.map((e) {
                  final brand = e.value;
                  return InkWell(
                    onTap: () => homeCtrl.goToShopAll(),
                    child: Container(
                        width: AppScreenUtil().screenWidth(120),
                        alignment: Alignment.center,
                        height: AppScreenUtil().screenHeight(55),
                        padding: EdgeInsets.symmetric(
                            vertical: AppScreenUtil().screenHeight(5),
                            horizontal: AppScreenUtil().screenWidth(8)),
                        margin: EdgeInsets.only(
                            left: AppScreenUtil()
                                .screenWidth(e.key == 0 ? 15 : 0),
                            right: AppScreenUtil().screenWidth(15),
                            top: AppScreenUtil().screenHeight(15),
                            bottom: AppScreenUtil().screenHeight(10)),
                        decoration: BoxDecoration(
                          color: homeCtrl.appCtrl.appTheme.greyLight25,
                          borderRadius: BorderRadius.circular(AppScreenUtil()
                              .borderRadius(5)),
                        ),
                        child: brand.image.isNotEmpty
                            ? FadeInImageLayout(
                                image: brand.image,
                                fit: BoxFit.contain,
                                width: AppScreenUtil().screenWidth(100),
                                height: AppScreenUtil().screenHeight(45),
                              )
                            : LatoFontStyle(
                                text: brand.name ?? '',
                                fontSize: FontSizes.f12,
                                fontWeight: FontWeight.w600,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                color:
                                    homeCtrl.appCtrl.appTheme.blackColor,
                              )),
                  );
                }).toList(),
              ))
        ],
      ).marginOnly(
          top: AppScreenUtil().screenHeight(20),
          bottom: AppScreenUtil().screenHeight(20));
    });
  }
}
