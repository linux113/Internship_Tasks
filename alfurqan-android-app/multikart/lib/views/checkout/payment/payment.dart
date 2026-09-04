import 'package:multikart/controllers/home_product_controllers/cart_controller.dart';

import '../../../config.dart';

/// PAYMENT (checkout step 3) — pehle "Pay Now" seedha STATIC success page
/// kholta tha (server par order kabhi nahi jata tha) + fake offers/cards
/// dikhte the. Ab: coupon box + COD selector (REAL OrderSaveDto fields) aur
/// PLACE ORDER button → CheckoutController.placeOrder() → server par asli
/// order (api/Orders/OrderPlace) → success page.
class Payment extends StatelessWidget {
  final paymentCtrl = Get.put(PaymentController());
  final checkoutCtrl = Get.put(CheckoutController());

  Payment({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(builder: (_) {
      return Directionality(
        textDirection: paymentCtrl.appCtrl.isRTL ||
            paymentCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: HomeProductAppBar(
            onTap: () => Get.back(),
            titleChild: CommonAppBarTitle(
              title: PaymentFont().paymentDetails,
              desc: PaymentFont().steps3Of3,
            ),
          ),
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //coupon box (REAL — OrderPlace body me jata hai)
                  const CheckoutCouponBox(),
                  const Space(0, 30),
                  const BorderLineLayout(),
                  const Space(0, 30),

                  //payment method (REAL — payment_method field)
                  const CheckoutPaymentSelector(),
                  const Space(0, 30),

                  //cart order detail(price) — SIRF REAL cart ka model.
                  // CRITICAL FIX: pehle fallback me STATIC demo `cartList`
                  // (fashion items) pass hota tha — cart transiently null
                  // hote hi FAKE data dikhne lagta tha. Ab koi bhi demo
                  // fallback NAHI.
                  CartOrderDetailLayout(
                      cartModelList: Get.isRegistered<CartController>()
                          ? Get.find<CartController>().cartModelList
                          : null,
                      isDeliveryShow: false),
                  const Space(0, 100)
                ],
              ).marginSymmetric(vertical: Insets.i20)),

              //PLACE ORDER — ab REAL server call (pehle static success page
              // seedha kholta tha!)
              CartBottomLayout(
                  desc: CartFont().viewDetail,
                  buttonName: checkoutCtrl.isPlacing
                      ? "Placing Order..."
                      : "Place Order",
                  totalAmount: paymentCtrl.totalAmount.toString(),
                  onTap: () {
                    if (!checkoutCtrl.isPlacing) checkoutCtrl.placeOrder();
                  })
            ],
          ),
        ),
      );
    });
  }
}
