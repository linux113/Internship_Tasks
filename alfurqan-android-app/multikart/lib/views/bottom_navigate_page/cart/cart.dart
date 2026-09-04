import '../../../config.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final cartCtrl = Get.put(CartController());

  @override
  void initState() {
    super.initState();
    // FIX (cart "auto-product" shikayat): CartController singleton rehne ki
    // wajah se dobara open karne par PURANA cart dikh sakta tha. Ab har
    // baar cart screen khulne par server se FRESH cart lao — purana/server
    // ka leftover item sirf tabhi dikhega jab server par sach me bacha ho
    // (use Remove se hataya ja sakta hai — ab server par bhi kaam karta hai).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartCtrl.getCart();
    });
  }

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
                              // RAW AED (server currency) — conversion ab
                              // CartBottomLayout KHUD karta hai (delivery/
                              // payment ke saath unified; pehle sirf cart
                              // convert karti thi isliye baaki pages galat
                              // amount dikhate the).
                              totalAmount:
                                  (cartCtrl.cartModelList!.totalAmount ?? 0)
                                      .toStringAsFixed(2),
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
