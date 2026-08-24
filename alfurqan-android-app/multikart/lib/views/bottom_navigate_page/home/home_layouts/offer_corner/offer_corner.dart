import 'package:multikart/config.dart';

/// Offer Corner — API ke baaki offer banners (Banner_2/Banner_3).
/// FIX: pehle yaha DEMO "Flat 50% OFF" tiles dikhti thi. Ab koi asli offer
/// banner nahi to poora section hide rehta hai.
class OfferCorner extends StatelessWidget {
  const OfferCorner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      if (homeCtrl.offerCornerBanners.isEmpty) {
        return const SizedBox.shrink();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
            text: HomeFont().offerCorner,
            fontSize: FontSizes.f14,
            fontWeight: FontWeight.w700,
            color: homeCtrl.appCtrl.appTheme.blackColor,
          ),
          const Space(0, 10),
          const OfferCornerLayout()
        ],
      ).paddingSymmetric(
          vertical: AppScreenUtil().screenHeight(10),
          horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
