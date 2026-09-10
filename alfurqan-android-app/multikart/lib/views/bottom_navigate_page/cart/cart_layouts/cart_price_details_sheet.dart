import '../../../../config.dart';

/// Cart/Payment page ke "View Details" ka ASLI content (10/09 user ask —
/// "view detail is not showing"): pehle wo text DEAD tha (tap = sirf
/// Get.back, kuch nahi dikhta tha). Ab tap par ye sheet khulti hai jisme
/// WOAHI price breakup hota hai jo payment page par hai — Bag total,
/// Bag savings (ho to), Coupon, Tax (18%), Delivery aur Total Amount.
/// Data source = live CartController.cartModelList (server cart + tax
/// service se banaya gaya) — koi static/demo row nahi.
class CartPriceDetailsSheet extends StatelessWidget {
  const CartPriceDetailsSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return GetBuilder<CartController>(builder: (cartCtrl) {
        final m = cartCtrl.cartModelList;
        final hasRows = m?.orderDetail != null;
        return SafeArea(
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: AppScreenUtil().screenHeight(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LatoFontStyle(
                      text: 'priceDetails'.tr,
                      fontWeight: FontWeight.w700,
                      fontSize: FontSizes.f16,
                      color: appCtrl.appTheme.blackColor,
                    ),
                    Icon(Icons.close,
                            size: AppScreenUtil().size(20),
                            color: appCtrl.appTheme.contentColor)
                        .gestures(onTap: () => Get.back()),
                  ],
                ).marginSymmetric(
                    horizontal: AppScreenUtil().screenWidth(15)),
                const Space(0, 6),
                Divider(color: appCtrl.appTheme.greyLight25),
                const Space(0, 6),
                if (hasRows)
                  CartOrderDetailLayout(
                    cartModelList: m,
                    isDeliveryShow: false,
                  )
                else
                  // Cart abhi load ho raha hai — jhoothi rows nahi, bas
                  // halka sa loading hint.
                  Center(
                    child: LatoFontStyle(
                      text: 'loadingData'.tr,
                      fontSize: FontSizes.f13,
                      color: appCtrl.appTheme.contentColor,
                    ).marginAll(AppScreenUtil().screenHeight(20)),
                  ),
              ],
            ),
          ),
        );
      });
    });
  }
}
