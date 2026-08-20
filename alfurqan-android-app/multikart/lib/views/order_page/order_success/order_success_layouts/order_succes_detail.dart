
import '../../../../config.dart';

class OrderSuccessDetail extends StatelessWidget {
  const OrderSuccessDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
              text: OrderSuccessFont().orderDetail,
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor,
              fontWeight: FontWeight.w700),
          const Space(0, 20),
          OrderSuccessWidget().commonDetailText(OrderSuccessFont().yourOrder, OrderSuccessFont().orderInfo),
          const Space(0, 20),
          OrderSuccessWidget().commonDetailText(OrderSuccessFont().orderShipped, OrderSuccessFont().orderShippedAddress),

          const Space(0, 20),
          OrderSuccessWidget().commonDetailText(OrderSuccessFont().paymentMethod, OrderSuccessFont().googleApi),
         
        ],
      ).width(MediaQuery.of(context).size.width).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
