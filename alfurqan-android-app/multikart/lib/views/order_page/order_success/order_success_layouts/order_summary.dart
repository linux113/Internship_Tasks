import '../../../../config.dart';

class OrderSummary extends StatelessWidget {
  const OrderSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: OrderSuccessFont().orderSummary,
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w700).paddingSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          const Space(0, 20),
          ...orderSummaryArray.asMap().entries.map((e) {
            return OrderSuccessCard(orderSummaryModel: e.value,index: e.key,);
          }).toList(),

          CartOrderDetailLayout(cartModelList: cartList,isDeliveryShow: false,isApplyText: false,),
          const Space(0, 50),
        ],
      )
          .width(MediaQuery.of(context).size.width)
          .marginSymmetric(vertical: AppScreenUtil().screenHeight(20));
    });
  }
}
