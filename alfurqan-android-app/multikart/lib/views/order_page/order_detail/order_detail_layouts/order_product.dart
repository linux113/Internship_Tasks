import '../../../../config.dart';

class OrderProduct extends StatelessWidget {
  const OrderProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Card(
          elevation: 2,
          color: appCtrl.appTheme.whiteColor,
          child: OrderSuccessCard(
            orderSummaryModel: orderSummaryArray[0],
            index: 0,
            isDivider: false,
          ).marginSymmetric(vertical: AppScreenUtil().screenHeight(15)),
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
      }
    );
  }
}
