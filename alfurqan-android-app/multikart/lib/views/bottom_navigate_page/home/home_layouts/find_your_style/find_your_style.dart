import '../../../../../config.dart';

class FindYourStyle extends StatelessWidget {
  const FindYourStyle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppScreenUtil().screenWidth(15),
            vertical: AppScreenUtil().screenHeight(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title/description API (Find_Your_Match) se — backend abhi
                // section-level Title nahi bhejta, to translated
                // "Find Your Match" fallback use hota hai.
                LatoFontStyle(
                  text: homeCtrl.matchSectionTitle.isNotEmpty
                      ? homeCtrl.matchSectionTitle
                      : HomeFont().findYourStyle,
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w700,
                  color: homeCtrl.appCtrl.appTheme.blackColor,
                ),
                LatoFontStyle(
                  text: homeCtrl.matchSectionDescription.isNotEmpty
                      ? homeCtrl.matchSectionDescription
                      : HomeFont().superSummerSale,
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w400,
                  color: homeCtrl.appCtrl.appTheme.contentColor,
                ),
                const FindYourStyleCategory(),
                const Space(0, 5),
                const FindStyleSubCategory()
              ],
            )
          ],
        ),
      );
    });
  }
}
