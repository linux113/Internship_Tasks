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
                        // 10/09 user ask: "all pages should have refresh" —
                        // pull-to-refresh = server se FRESH cart (silent).
                        RefreshIndicator(
                            color: const Color(0xFF044015),
                            onRefresh: () async =>
                                cartCtrl.getCart(silent: true),
                            // 17/09: bottom bar (Price/PLACE ORDER) content ke
                            // UPAR float karta hai — bina bottom padding ke
                            // aakhri section (Coupons/View Coupons) uske
                            // peeche CHHUP jata tha (Lalit ke screenshot me
                            // "View Coupons" aadha kata dikh raha tha).
                            child: const SingleChildScrollView(
                                physics: AlwaysScrollableScrollPhysics(),
                                padding: EdgeInsets.only(bottom: 110),
                                child: CartBody())),
                        if (cartCtrl.cartModelList != null)
                          CartBottomLayout(
                              desc: CartFont().viewDetail,
                              buttonName: CartFont().placeOrder,
                              // "View Details" = ASLI price breakup sheet
                              // (Bag total / Tax / Delivery / Total) —
                              // pehle tap par sirf wapas chala jata tha.
                              // Centralized opener (capped height — full-
                              // screen khaali grey flash KABHI nahi).
                              onDescTap: () => CartPriceDetailsSheet.show(),
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
