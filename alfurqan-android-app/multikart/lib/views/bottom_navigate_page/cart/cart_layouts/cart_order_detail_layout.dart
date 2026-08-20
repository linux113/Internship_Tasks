
import 'package:multikart/config.dart';

class CartOrderDetailLayout extends StatelessWidget {
  final CartModel? cartModelList;
  final bool isDeliveryShow, isApplyText;

  const CartOrderDetailLayout(
      {Key? key,
      this.isDeliveryShow = true,
      this.cartModelList,
      this.isApplyText = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return cartModelList!.orderDetail != null ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ...cartModelList!.orderDetail!.map((e) {

          String val;
          if ((e.title == "Bag savings" || e.title == "बैग बचत" || e.title == "توفير الحقيبة" || e.title == "가방 절약")) {
            val = "-${appCtrl.priceSymbol}${(e.value * appCtrl.rateValue).toStringAsFixed(2)}";
          } else if ((e.value == "Apply Coupon" ||e.value == "कूपन लागू करें" ||e.value == "쿠폰 적용ं"  ||e.value == "تطبيق القسائم" )) {
            val = e.value;
          } else {
            val = "${appCtrl.priceSymbol}${(e.value * appCtrl.rateValue).toStringAsFixed(2)}";
          }
          return  CartDetail(
            isApplyText: isApplyText,
            totalAmount: cartModelList!.totalAmount.toString(),
            val: val.tr,
            orderDetail: e,
          );
        }).toList(),
        Divider(color: appCtrl.appTheme.greyLight25),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          LatoFontStyle(
              text: CartFont().totalAmount.tr,
              fontSize: FontSizes.f14,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w600),
          LatoFontStyle(
              text: "${appCtrl.priceSymbol}${(cartModelList!.totalAmount! * appCtrl.rateValue).toStringAsFixed(2)}",
              fontSize: FontSizes.f14,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w600)
        ]).marginOnly(bottom: AppScreenUtil().screenHeight(10)),
        if (isDeliveryShow)
          if (cartModelList != null)
            DeliveryCharges(
                deliveryChargesInstruction:
                    cartModelList!.deliveryChargesInstruction)
      ]).marginSymmetric(
          horizontal: AppScreenUtil().screenWidth(15),) : Container();
    });
  }
}
