import '../../../../config.dart';
import '../../../../controllers/checkout_controller/checkout_controller.dart';

/// ORDER SUCCESS DETAIL — pehle yaha STATIC "3501 Maloy Court, New York"
/// jaisa FAKE address + "Your order # is: 64484032" fake number aata tha.
/// Ab REAL: sirf wahi address jo user ne delivery ke liye select kiya
/// (CheckoutController.lastPlacedOrder['address'] — order place hone se
/// pehle ka snapshot) + REAL order id (server response se).
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
      final String address = (order?['address'] ?? '').toString().trim();
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
                  ? "#$orderId"
                  : OrderSuccessFont().orderInfo),
          const Space(0, 20),
          // REAL shipping address — static New York text hata diya; address
          // pata na ho to section hi hide (koi fake line nahi).
          if (address.isNotEmpty) ...[
            OrderSuccessWidget().commonDetailText(
                OrderSuccessFont().orderShipped, address),
            const Space(0, 20),
          ],
          OrderSuccessWidget()
              .commonDetailText(OrderSuccessFont().paymentMethod, payment),
        ],
      ).width(MediaQuery.of(context).size.width).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
