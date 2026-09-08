import '../../config.dart';
import '../../controllers/pages_controller/rating_review_controller.dart';

class RatingReviewBottomLayout extends StatelessWidget {
  const RatingReviewBottomLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<RatingReviewController>(
      builder: (c) {
        final appCtrl = c.appCtrl;
        return Container(
            width: MediaQuery.of(Get.context!).size.width,
            padding: EdgeInsets.symmetric(
                vertical: AppScreenUtil().screenHeight(12),
                horizontal: AppScreenUtil().screenWidth(15)),
            decoration: BoxDecoration(
              color: appCtrl.appTheme.whiteColor,
              boxShadow: [
                BoxShadow(
                  color: appCtrl.appTheme.lightGray,
                  spreadRadius: 10,
                  blurRadius: 5,
                  offset: const Offset(0, 7), // changes position of shadow
                )
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // BACK — pehle dead text tha (tap nahi hota tha)
                    InkWell(
                      onTap: () => Get.back(),
                      child: LatoFontStyle(
                          text: CardBalanceFont().back.toUpperCase(),
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizes.f14),
                    ),
                    VerticalDivider(
                      color: appCtrl.appTheme.greyLight25,
                    ),
                    // FIX (08/09 — "rating dene par 0 hi rehta hai"): SUBMIT
                    // ka onTap EXIST hi nahi karta tha — 100% decorative
                    // button tha! Ab REAL server submit.
                    CustomButton(
                      title: c.isSubmitting
                          ? "${OrderHistoryFont().submit.toUpperCase()}..."
                          : OrderHistoryFont().submit.toUpperCase(),
                      width: AppScreenUtil().screenWidth(100),
                      height: AppScreenUtil().screenHeight(30),
                      onTap: () => c.submit(),
                    )
                  ]),
            ));
      }
    );
  }
}
