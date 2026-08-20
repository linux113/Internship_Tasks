import '../../../../config.dart';

class OrderSummarySizeQuantity extends StatelessWidget {
  final OrderSummaryModel? orderSummaryModel;
  const OrderSummarySizeQuantity({Key? key,this.orderSummaryModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return Row(children: [
          LatoFontStyle(
              text: OrderHistoryFont().size,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f13,
              color: appCtrl.appTheme.contentColor),
          const Space(5, 0),
          LatoFontStyle(
              text: orderSummaryModel!.size,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f13,
              color: appCtrl.appTheme.contentColor),
          const Space(10, 0),
          LatoFontStyle(
              text: OrderHistoryFont().qty,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f13,
              color: appCtrl.appTheme.contentColor),
          const Space(5, 0),
          LatoFontStyle(
              text: orderSummaryModel!.qty.toString(),
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f13,
              color: appCtrl.appTheme.contentColor),
        ]);
      }
    );
  }
}
