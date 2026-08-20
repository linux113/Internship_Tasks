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

              //you may also like layout
              ProductDetailWidget().commonText(
                  text: CartFont().youMayAlsoLike,
                  fontSize: FontSizes.f14),

              //similar product layout
              SimilarProductLayout(
                  data: cartCtrl.similarList, bottom: 30),
              const BorderLineLayout(),

              //coupon text layout
              ProductDetailWidget().commonText(
                  text: CartFont().coupons, fontSize: FontSizes.f14),
              const Space(0, 20),
              //coupon text box layout
              const CouponTextBox(),
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
