import '../../../../../config.dart';

/// Bada offer banner (API ke Offer_Banner.Banner_1 se).
/// FIX: pehle yaha 100% DEMO "Denim Wear / Sales Starts In / 15-10-35 timer"
/// section tha (fashion girl asset image + hardcoded text). Ab sirf asli
/// offer banner dikhta hai — backend se banner nahi aaya to ye section
/// bilkul hide rehta hai.
class OfferTimeLayout extends StatelessWidget {
  const OfferTimeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      final banner = homeCtrl.mainOfferBanner;
      if (banner == null || banner.image.isEmpty) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppScreenUtil().screenWidth(15),
            vertical: AppScreenUtil().screenHeight(10)),
        child: InkWell(
          onTap: () => homeCtrl.openOfferBanner(banner),
          splashColor: Colors.transparent,
          child: ClipRRect(
            borderRadius:
                BorderRadius.circular(AppScreenUtil().borderRadius(10)),
            child: FadeInImageLayout(
              image: banner.image,
              fit: BoxFit.cover,
              width: MediaQuery.of(context).size.width,
              height: AppScreenUtil().size(140),
            ),
          ),
        ),
      );
    });
  }
}
