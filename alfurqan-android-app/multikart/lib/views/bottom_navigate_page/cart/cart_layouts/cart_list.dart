import 'package:multikart/config.dart';

class CartList extends StatelessWidget {
  const CartList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(builder: (cartCtrl) {
      return cartCtrl.cartModelList != null
          ? InkWell(
              onTap: () => cartCtrl.appCtrl.goToProductDetail(),
              splashColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
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
                                                      .size(110))),
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
                                        secondActionTap: () =>
                                            cartCtrl.bottomSheetLayout(
                                                CommonTextFont().remove))
                                  ]).marginSymmetric(
                                  horizontal: AppScreenUtil().screenWidth(14),
                                  vertical: AppScreenUtil().screenHeight(15)),
                              const BorderLineLayout()
                            ],
                          )),
                ],
              ),
            )
          : Container();
    });
  }
}
