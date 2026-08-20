import '../../../../config.dart';

class RatingLayout extends StatelessWidget {
  const RatingLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      double rating = productCtrl.product.ratingPoints ?? 0;
      return Row(
        children: [
          Rating(
            val: productCtrl.product.rating ?? 0,
            onRatingUpdate: (val) {},
          ),
          const Space(5, 0),
          LatoFontStyle(
            text: "(${rating.round()} ${ProductDetailFont().ratings})".toString(),
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: productCtrl.appCtrl.appTheme.contentColor,
          )
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(12),vertical: AppScreenUtil().screenHeight(2));
    });
  }
}
