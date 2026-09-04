import '../../../../config.dart';

/// CHECKOUT PAYMENT OPTIONS — pehle payment page par STATIC fake offers
/// list + fake card/wallet/bank payment methods dikhte the (backend se koi
/// connection nahi tha). Ab:
///   1) Coupon box — REAL (OrderPlace body me 'coupon' field me jata hai)
///   2) Payment method — Cash on Delivery (pehla supported method)
class CheckoutCouponBox extends StatelessWidget {
  const CheckoutCouponBox({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutCtrl) {
      final appCtrl = checkoutCtrl.appCtrl;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: "couponCode".tr,
              fontSize: FontSizes.f16,
              fontWeight: FontWeight.w700),
          const Space(0, 12),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: AppScreenUtil().screenWidth(12)),
            decoration: BoxDecoration(
                color: appCtrl.appTheme.greyLight25,
                borderRadius:
                    BorderRadius.circular(AppScreenUtil().borderRadius(6))),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: checkoutCtrl.txtCoupon,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: "couponHint".tr,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                        fontSize: FontSizes.f13,
                        color: appCtrl.appTheme.contentColor),
                  ),
                  style: TextStyle(
                      fontSize: FontSizes.f14,
                      color: appCtrl.appTheme.blackColor),
                ),
              ),
              LatoFontStyle(
                      text: "viewCoupons".tr,
                      color: appCtrl.appTheme.primary,
                      fontSize: FontSizes.f13,
                      fontWeight: FontWeight.w600)
                  .gestures(onTap: () => Get.toNamed(routeName.coupons)),
            ]),
          ),
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}

class CheckoutPaymentSelector extends StatelessWidget {
  const CheckoutPaymentSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (checkoutCtrl) {
      final appCtrl = checkoutCtrl.appCtrl;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: "paymentMethod".tr,
              fontSize: FontSizes.f16,
              fontWeight: FontWeight.w700),
          const Space(0, 12),
          // ---- Cash on Delivery (selected by default) ----
          GestureDetector(
            onTap: () {
              checkoutCtrl.paymentMethod = 'cod';
              checkoutCtrl.update();
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppScreenUtil().screenWidth(15),
                  vertical: AppScreenUtil().screenHeight(14)),
              decoration: BoxDecoration(
                  color: appCtrl.appTheme.greyLight25,
                  borderRadius:
                      BorderRadius.circular(AppScreenUtil().borderRadius(6)),
                  border: Border.all(
                      color: checkoutCtrl.paymentMethod == 'cod'
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.greyLight25,
                      width: 1.5)),
              child: Row(children: [
                Icon(
                    checkoutCtrl.paymentMethod == 'cod'
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: appCtrl.appTheme.primary,
                    size: AppScreenUtil().size(20)),
                const Space(12, 0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatoFontStyle(
                            text: "cashOnDelivery".tr,
                            fontSize: FontSizes.f14,
                            fontWeight: FontWeight.w600,
                            color: appCtrl.appTheme.blackColor),
                        LatoFontStyle(
                            text: "codSubtitle".tr,
                            fontSize: FontSizes.f11,
                            color: appCtrl.appTheme.contentColor),
                      ]),
                ),
              ]),
            ),
          ),
          const Space(0, 10),
          LatoFontStyle(
              text: "onlineComingSoon".tr,
              fontSize: FontSizes.f11,
              color: appCtrl.appTheme.contentColor),
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
