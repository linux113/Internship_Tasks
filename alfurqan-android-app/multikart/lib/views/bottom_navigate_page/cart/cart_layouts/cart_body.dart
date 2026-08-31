import '../../../../config.dart';

class CartBody extends StatelessWidget {
  const CartBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CartController>(
      builder: (cartCtrl) {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //cart list layout
              if (cartCtrl.cartModelList != null) const CartList(),

              //you may also like layout — REAL products (demo fashion nahi);
              //koi real suggestion na ho to section hi hide
              if (cartCtrl.similarList.isNotEmpty) ...[
                ProductDetailWidget().commonText(
                    text: CartFont().youMayAlsoLike,
                    fontSize: FontSizes.f14),

                //similar product layout
                SimilarProductLayout(
                    data: cartCtrl.similarList, bottom: 30),
                const BorderLineLayout(),
              ],

              //coupon section — pehle sirf dead "Coupons:" heading + aisa
              // text box tha jo kuch nahi karta tha. Ab FUNCTIONAL:
              // "View Coupons" se asli coupons page khulta hai; waha APPLY
              // karne se code yaha chip me dikhta hai (X se hata sakte ho),
              // aur Place Order par apne aap lag jata hai.
              Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProductDetailWidget().commonText(
                        text: CartFont().coupons, fontSize: FontSizes.f14),
                    LatoFontStyle(
                            text: "View Coupons",
                            color: cartCtrl.appCtrl.appTheme.primary,
                            fontSize: FontSizes.f14,
                            fontWeight: FontWeight.w600)
                        .gestures(onTap: () {
                      Get.toNamed(routeName.coupons,
                          arguments:
                              cartCtrl.cartModelList?.totalAmount ?? 0);
                    }),
                  ]),
              if (cartCtrl.appliedCoupon.isNotEmpty) ...[
                const Space(0, 12),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: AppScreenUtil().screenWidth(12),
                      vertical: AppScreenUtil().screenHeight(8)),
                  decoration: BoxDecoration(
                      color: cartCtrl.appCtrl.appTheme.greyLight25,
                      borderRadius: BorderRadius.circular(
                          AppScreenUtil().borderRadius(5))),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LatoFontStyle(
                            text: "Applied: ${cartCtrl.appliedCoupon}",
                            fontSize: FontSizes.f13,
                            fontWeight: FontWeight.w600,
                            color: cartCtrl.appCtrl.appTheme.primary),
                        const DeleteIcon()
                            .gestures(onTap: () => cartCtrl.clearCoupon()),
                      ]),
                ),
              ],
              const Space(0, 15),
              const BorderLineLayout(),

              //order detail text layout
              ProductDetailWidget().commonText(
                  text: "${CartFont().orderDetail}:",
                  fontSize: FontSizes.f14),
              const Space(0, 20),
              //cart order detail
              if (cartCtrl.cartModelList != null)
                CartOrderDetailLayout(
                    cartModelList: cartCtrl.cartModelList),
              const Space(0, 20),
              const BorderLineLayout(),
              if (cartCtrl.cartModelList != null)

              //delivery instruction
                DeliveryInstruction(
                    deliveryInstruction:
                    cartCtrl.cartModelList!.deliveryInstruction)
            ]).marginOnly(bottom: AppScreenUtil().screenHeight(50));
      }
    );
  }
}
