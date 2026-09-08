import 'package:multikart/widgets/common/rating_review_bottom_layout.dart';

import '../../config.dart';
import '../../controllers/pages_controller/rating_review_controller.dart';

class RatingReview extends StatelessWidget {
  /// REAL server product id — isi par review POST hoga (08/09 — pehle
  /// sheet 100% decorative thi: SUBMIT ka onTap hi nahi tha!).
  final int? productId;

  const RatingReview({Key? key, this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reviewCtrl = Get.put(RatingReviewController(productId: productId ?? 0));
    return GetBuilder<RatingReviewController>(builder: (c) {
      return Directionality(
        textDirection: c.appCtrl.isRTL || c.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                LatoFontStyle(
                    text: OrderHistoryFont().writeReview,
                    fontSize: FontSizes.f14,
                    fontWeight: FontWeight.w700,
                    color: c.appCtrl.appTheme.blackColor),
                const Space(0, 10),
                Row(
                  children: [
                    LatoFontStyle(
                        text: OrderHistoryFont().yourRating,
                        fontSize: FontSizes.f14,
                        fontWeight: FontWeight.w600,
                        color: c.appCtrl.appTheme.contentColor,
                        overflow: TextOverflow.clip),
                    const Space(10, 0),
                    // REAL: stars ka selection controller me save hota hai
                    // (pehle callback khaali tha — select karne par kuch
                    // nahi hota tha).
                    Rating(
                      val: c.ratingVal,
                      onRatingUpdate: c.setRating,
                    )
                  ],
                ),
                const Space(0, 10),
                CustomTextFormField(
                    controller: c.textCtrl,
                    keyboardType: TextInputType.multiline,
                    maxLines: 7,
                    minLines: 7)
              ],
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
            const RatingReviewBottomLayout()
          ],
        ).height(AppScreenUtil().screenHeight(250)),
      );
    });
  }
}
