import '../../../../config.dart';

class ProductReviewLayout extends StatelessWidget {
  const ProductReviewLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProductDetailController>(builder: (productCtrl) {
      final product = productCtrl.product;
      // 10/09 STRICT-fix: count KABHI "(null)" nahi dikhega — compact
      // payloads (home sections) me totalReview null rehta tha aur seedha
      // string me print ho jata tha. Fallback: list ki length, phir 0.
      final int total = product.totalReview ?? product.reviews?.length ?? 0;
      final reviewList = product.reviews ?? const [];
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LatoFontStyle(
                text: "${ProductDetailFont().customerReviews} ($total)",
                fontWeight: FontWeight.w700,
                fontSize: FontSizes.f14,
                color: productCtrl.appCtrl.appTheme.blackColor,
              ),
              if (reviewList.isNotEmpty)
                LatoFontStyle(
                  text: ProductDetailFont().allReviews,
                  fontSize: FontSizes.f12,
                  color: productCtrl.appCtrl.appTheme.primary,
                )
            ],
          ),
          if (reviewList.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...reviewList.asMap().entries.map((e) {
                  return ReviewCard(
                    reviews: e.value,
                    index: e.key,
                    lastIndex: reviewList.length - 1,
                  );
                }).toList()
              ],
            )
          else
            // Honest empty state — static/demo review kabhi nahi dikhana,
            // bas seedha batao ki abhi koi review nahi hai.
            LatoFontStyle(
              text: "noReviewsYet".tr,
              fontWeight: FontWeight.normal,
              fontSize: FontSizes.f13,
              color: productCtrl.appCtrl.appTheme.contentColor,
            ).marginOnly(top: AppScreenUtil().screenHeight(12)),
        ],
      ).marginSymmetric(
          horizontal: AppScreenUtil().screenWidth(15),
          vertical: AppScreenUtil().screenHeight(20));
    });
  }
}
