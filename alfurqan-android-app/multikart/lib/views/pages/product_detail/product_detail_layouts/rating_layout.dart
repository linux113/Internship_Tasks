import '../../../../config.dart';
import '../../../../widgets/common/rating_review.dart';

class RatingLayout extends StatelessWidget {
  const RatingLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      double rating = productCtrl.product.ratingPoints ?? 0;
      // USER KI APNI rating (uske submit ke baad locally saved) — server
      // approval queue rahega to count turant nahi badhta, par user ko
      // uski rating turant dikhni chahiye (08/09 "rating dene par 0").
      final pid = productCtrl.apiProduct?.id ?? 0;
      double myRating = 0;
      try {
        final raw = LocalStorage().read('my_ratings');
        if (raw is Map) {
          myRating = double.tryParse(
                  (raw as Map)['$pid']?.toString() ?? '0') ??
              0;
        }
      } catch (_) {}
      final serverStars = productCtrl.product.rating ?? 0;
      final stars = serverStars > 0 ? serverStars : myRating;
      final count = rating.round() > 0
          ? rating.round()
          : (myRating > 0 ? 1 : 0);
      return Row(
        children: [
          Rating(
            val: stars,
            // 08/09 DEEP-fix: stars ka callback pehle KHAALI tha — user
            // rating deta tha aur kuch hota hi nahi (isliye "0 hi rehta
            // hai" complaint). Ab stars tap = REAL review sheet khulti hai
            // (server POST) — sirf api product par (demo par nahi).
            onRatingUpdate: (val) {
              if (productCtrl.apiProduct == null || pid <= 0) return;
              Get.bottomSheet(
                RatingReview(productId: pid),
                backgroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
              );
            },
          ),
          const Space(5, 0),
          LatoFontStyle(
            text: "($count ${ProductDetailFont().ratings})".toString(),
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: productCtrl.appCtrl.appTheme.contentColor,
          )
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(12),vertical: AppScreenUtil().screenHeight(2));
    });
  }
}
