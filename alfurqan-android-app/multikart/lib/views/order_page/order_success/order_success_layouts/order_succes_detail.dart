import '../../../../config.dart';
import '../../../../controllers/checkout_controller/checkout_controller.dart';

/// ORDER SUCCESS DETAIL — FIX (Issue #3): pehle payment method ke neeche
/// STATIC "Google Api" jaisa fake text aata tha. Ab REAL data: order id
/// (ho to) + payment method (COD) + store address line.
class OrderSuccessDetail extends StatelessWidget {
  const OrderSuccessDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      final order = CheckoutController.lastPlacedOrder;
      final int orderId =
          int.tryParse(order?['orderId']?.toString() ?? '0') ?? 0;
      final String payment =
          (order?['payment'] ?? 'Cash on Delivery').toString();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: OrderSuccessFont().orderDetail,
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w700),
          const Space(0, 20),
          OrderSuccessWidget().commonDetailText(
              OrderSuccessFont().yourOrder,
              orderId > 0
                  ? "Order #$orderId — ${OrderSuccessFont().orderInfo}"
                  : OrderSuccessFont().orderInfo),
          const Space(0, 20),
          OrderSuccessWidget().commonDetailText(
              OrderSuccessFont().orderShipped,
              OrderSuccessFont().orderShippedAddress),
          const Space(0, 20),
          OrderSuccessWidget()
              .commonDetailText(OrderSuccessFont().paymentMethod, payment),
        ],
      ).width(MediaQuery.of(context).size.width).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
