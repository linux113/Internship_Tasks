import '../../../../config.dart';

/// Cart/Delivery/Payment page ke "View Details" ka ASLI content (10/09 user
/// ask — "view detail is not showing"): pehle wo text DEAD tha (tap = sirf
/// Get.back, kuch nahi dikhta tha). Ab tap par ye sheet khulti hai jisme
/// WOAHI price breakup hota hai jo payment page par hai — Bag total,
/// Bag savings (ho to), Coupon, Tax, Delivery aur Total Amount.
/// Data source = live CartController.cartModelList (server cart + tax
/// service se banaya gaya) — koi static/demo row nahi.
class CartPriceDetailsSheet extends StatelessWidget {
  const CartPriceDetailsSheet({Key? key}) : super(key: key);

  /// 15/09 user report: sheet kabhi-kabhi poori screen par KHAALI grey
  /// flash karti thi, phir content aata tha (unconstrained bottom-sheet
  /// height ka first-frame race). Ab EK hi centralized opener hai jo
  /// teenon checkout steps (cart / delivery / payment) use karte hai:
  ///   - height screen ke 80% par CAPPED — kabhi full-screen grey nahi
  ///   - opaque white bg + rounded top + dark barrier (grey flash NAHI)
  ///   - rows scrollable — chhoti screen par bhi overflow NAHI
  static Future<void> show() {
    return Get.bottomSheet(
      ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Get.height * 0.8),
        child: const CartPriceDetailsSheet(),
      ),
      backgroundColor: Colors.white,
      barrierColor: Colors.black54,
      isScrollControlled: true,
      ignoreSafeArea: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
    );
  }

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
                // Rows scrollable — lamba breakup (coupon+savings) chhoti
                // screen par capped height ke andar scroll hoga.
                SingleChildScrollView(
                  child: hasRows
                      ? CartOrderDetailLayout(
                          cartModelList: m,
                          isDeliveryShow: false,
                        )
                      // Cart abhi load ho raha hai — jhoothi rows nahi, bas
                      // halka sa loading hint.
                      : Center(
                          child: LatoFontStyle(
                            text: 'loadingData'.tr,
                            fontSize: FontSizes.f13,
                            color: appCtrl.appTheme.contentColor,
                          ).marginAll(AppScreenUtil().screenHeight(20)),
                        ),
                ),
              ],
            ),
          ),
        );
      });
    });
  }
}
