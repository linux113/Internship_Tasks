import '../../../config.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartCtrl = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (_) {
      return Directionality(
        textDirection:
            cartCtrl.appCtrl.isRTL || cartCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: Scaffold(
            body: cartCtrl.appCtrl.isShimmer
                ? const CartShimmer()
                : cartCtrl.cartModelList != null
                    ? Stack(alignment: Alignment.bottomCenter, children: [
                        const SingleChildScrollView(child: CartBody()),
                        if (cartCtrl.cartModelList != null)
                          CartBottomLayout(
                              desc: CartFont().viewDetail,
                              buttonName: CartFont().placeOrder,
                              totalAmount:
                                  (double.parse(cartCtrl
                                              .cartModelList!.totalAmount
                                              .toString()) *
                                          cartCtrl.appCtrl.rateValue).toStringAsFixed(2),
                              onTap: () {
                                cartCtrl.appCtrl.isHeart = false;
                                cartCtrl.update();
                                Get.toNamed(routeName.deliveryDetail,
                                    arguments:
                                        cartCtrl.cartModelList!.totalAmount);
                              })
                      ])
                    : const EmptyCart()),
      );
    });
  }
}
