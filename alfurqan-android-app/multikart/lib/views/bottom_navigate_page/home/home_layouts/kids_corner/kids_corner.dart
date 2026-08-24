import '../../../../../config.dart';

class KidsCorner extends StatelessWidget {
  const KidsCorner({Key? key}) : super(key: key);

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
                // Title/description API (Tranding_Products) se —
                // "Trending Products" / "Deals on trending product"
                LatoFontStyle(
                  text: homeCtrl.trendingTitle.isNotEmpty
                      ? homeCtrl.trendingTitle
                      : HomeFont().theKidsCorner,
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w700,
                  color: homeCtrl.appCtrl.appTheme.blackColor,
                ),
                LatoFontStyle(
                  text: homeCtrl.trendingDescription.isNotEmpty
                      ? homeCtrl.trendingDescription
                      : HomeFont().clothingForYourLilOne,
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w400,
                  color: homeCtrl.appCtrl.appTheme.contentColor,
                ),
              
                const Space(0, 5),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      homeCtrl.homeKidsCornerList.length,
                          (index) => FindStyleListCard(
                        data: homeCtrl.homeKidsCornerList[index],
                        index: index,
                        isFit: true,
                        isDiscountShow: false,
                            source: "kids",
                        // real product detail page khule (demo nahi)
                        onTap: () => homeCtrl.openProductById(
                            homeCtrl.homeKidsCornerList[index].id),

                      ).paddingOnly(
                        right: AppScreenUtil().screenWidth(10),
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        ),
      );
    });
  }
}