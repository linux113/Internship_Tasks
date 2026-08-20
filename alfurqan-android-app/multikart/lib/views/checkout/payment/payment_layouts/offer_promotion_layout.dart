import '../../../../config.dart';

class OfferPromotionLayout extends StatelessWidget {
  const OfferPromotionLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PaymentController>(builder: (paymentCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: PaymentFont().offerAndPromotion,
              fontSize: FontSizes.f16,
              fontWeight: FontWeight.w700),
          const Space(0, 20),
          ListView.builder(
            shrinkWrap: true,
            itemCount: paymentCtrl.seeAll
                ? AppArray().offerAndPromotionList.length
                : 2,
            itemBuilder: (context, index) {
              return PaymentWidget().offerPromotionCard(
                  AppArray().offerAndPromotionList[index]['title']);
            },
          ),
          LatoFontStyle(
                  text: paymentCtrl.seeAll
                      ? PaymentFont().showLess
                      : "${PaymentFont().showMore}(${AppArray().offerAndPromotionList.length} ${PaymentFont().offers})",
                  color: paymentCtrl.appCtrl.appTheme.primary,
                  fontSize: FontSizes.f12,
                  fontWeight: FontWeight.w600)
              .gestures(onTap: () {
            paymentCtrl.seeAll = !paymentCtrl.seeAll;
            paymentCtrl.update();
          }).alignment(Alignment.center)
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
