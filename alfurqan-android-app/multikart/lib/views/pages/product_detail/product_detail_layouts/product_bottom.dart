import '../../../../config.dart';

class ProductBottom extends StatelessWidget {
  const ProductBottom({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Container(
          width: MediaQuery.of(context).size.width,
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
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 10/09 user ask: "add to cart ke andar price dikhao" — quantity
              // badhane par total bhi LIVE update hota hai (2 × AED30 =
              // AED60). Unit price = wahi jo page par dikhta hai (sale ho to
              // sale, warna price) — same formula jo ProductPrice use karta hai.
              GetBuilder<ProductDetailController>(builder: (pdCtrl) {
                final prod = pdCtrl.product;
                if (prod.price == null && prod.discountPrice == null) {
                  return const SizedBox.shrink();
                }
                final int qty = (prod.quantity ?? 1) <= 0 ? 1 : (prod.quantity ?? 1);
                final double unit =
                    ((prod.discountPrice ?? prod.price) ?? 0.0) *
                        appCtrl.rateValue;
                final double lineTotal = unit * qty;
                final String unitTxt =
                    '${appCtrl.priceSymbol} ${unit.toStringAsFixed(2)}';
                final String totalTxt =
                    '${appCtrl.priceSymbol} ${lineTotal.toStringAsFixed(2)}';
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LatoFontStyle(
                      text: qty > 1 ? '$qty × $unitTxt' : unitTxt,
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.f14,
                      color: appCtrl.appTheme.contentColor,
                    ),
                    LatoFontStyle(
                      text: qty > 1 ? totalTxt : '',
                      fontWeight: FontWeight.w700,
                      fontSize: FontSizes.f16,
                      color: appCtrl.appTheme.blackColor,
                    ),
                  ],
                ).marginOnly(bottom: AppScreenUtil().screenHeight(8));
              }),
              IntrinsicHeight(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  // FIX: pehle sirf wishlist tab khulti thi, product SAVE nahi
                  // hota tha — ab pehle save hota hai phir wishlist khulti hai.
                  onTap: () => Get.find<ProductDetailController>()
                      .addToWishlistAndOpen(),
                  child: Row(
                    children: [
                      HeartIcon(
                        color: appCtrl.appTheme.blackColor,
                      ),
                      const Space(10, 0),
                       LatoFontStyle(
                        text: ProductDetailFont().wishList,
                        fontWeight: FontWeight.w600,
                        fontSize: FontSizes.f14,
                      )
                    ],
                  ),
                ),
                VerticalDivider(color: appCtrl.appTheme.greyLight25 ,),
                InkWell(
                  // Real Cart/AddToCart api call -> success par cart tab open.
                  onTap: () =>
                      Get.find<ProductDetailController>().onAddToCartTap(),
                  child: Row(
                    children: [
                      BuyIcon(
                        color: appCtrl.appTheme.primary,
                      ),
                      const Space(10, 0),
                      LatoFontStyle(
                        text: ProductDetailFont().addToBag,
                        fontWeight: FontWeight.w600,
                        color: appCtrl.appTheme.primary,
                        fontSize: FontSizes.f14,
                      )
                    ],
                  ),
                ),
              ],
            ),
              ),
            ],
          ),
        );
      }
    );
  }
}
