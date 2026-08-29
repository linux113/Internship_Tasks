import 'package:multikart/config.dart';

class CartList extends StatelessWidget {
  const CartList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartCtrl) {
      return cartCtrl.cartModelList != null
          ? Column(
              children: [
                ...cartCtrl.cartModelList!.cartList!
                    .asMap()
                    .entries
                    .map((e) => Column(
                          children: [
                            Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        // image tap -> usi REAL product ka
                                        // detail khule (pehle puri list par ek
                                        // hi InkWell tha jo bina-product wala
                                        // DEMO "cloths" detail page kholta tha
                                        // — Remove dabate waqt bhi wo khul
                                        // jata tha!)
                                        ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppScreenUtil()
                                                            .borderRadius(3)),
                                                child: FadeInImageLayout(
                                                    image: e.value.image,
                                                    fit: BoxFit.cover,
                                                    height:
                                                        AppScreenUtil().size(110),
                                                    width: AppScreenUtil()
                                                        .size(110)))
                                            .gestures(onTap: () {
                                          final api =
                                              cartCtrl.productFor(e.value.id);
                                          if (api != null) {
                                            cartCtrl.appCtrl.goToProductDetail(
                                                arguments: api);
                                          }
                                        }),
                                        if (e.value.isTrending!)
                                          const TrendingButton()
                                      ]),
                                  const Space(10, 0),
                                  DealsOfTheDayContent(
                                      data: e.value,
                                      isVariantsShow: true,
                                      isActionShow: false,
                                      // books me Size/Qty dropdown fake lagta tha — hide kar diya
                                      showVariantOptions: false,
                                      // "Move to wishlist" AB REAL save hota hai
                                      firstActionTap: () =>
                                          cartCtrl.moveToWishlist(e.value),
                                      // REMOVE ab REAL remove karta hai
                                      // (pehle sirf demo bottom sheet tha)
                                      secondActionTap: () =>
                                          cartCtrl.removeFromCart(e.value))
                                ]).marginSymmetric(
                                horizontal: AppScreenUtil().screenWidth(14),
                                vertical: AppScreenUtil().screenHeight(15)),
                            const BorderLineLayout()
                          ],
                        )),
              ],
            )
          : Container();
    });
  }
}
