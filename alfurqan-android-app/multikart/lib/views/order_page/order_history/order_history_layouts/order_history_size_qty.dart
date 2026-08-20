import '../../../../config.dart';

class OrderHistorySizeQty extends StatelessWidget {
  final DaysWiseList? daysWiseList;

  const OrderHistorySizeQty({Key? key, this.daysWiseList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LatoFontStyle(
            text: daysWiseList!.name.toString().tr,
            fontWeight: FontWeight.w600,
            fontSize: FontSizes.f14,
            color: appCtrl.appTheme.blackColor),
        Row(children: [
          OrderHistoryWidget().commonText(OrderHistoryFont().size),
          const Space(5, 0),
          OrderHistoryWidget().commonText(daysWiseList!.size),
          const Space(10, 0),
          OrderHistoryWidget().commonText(OrderHistoryFont().qty),
          const Space(5, 0),
          OrderHistoryWidget().commonText(daysWiseList!.qty.toString()),
        ]),
        const Space(0, 5),
        OrderHistoryWidget()
            .viewDetailText(daysWiseList!.status, daysWiseList!.deliveryStatus),
      ]).marginOnly(left: AppScreenUtil().screenWidth(appCtrl.isRTL ||
          appCtrl.languageVal == "ar" ? 0 :15),right: AppScreenUtil().screenWidth(appCtrl.isRTL ||
          appCtrl.languageVal == "ar" ? 15:0));
    });
  }
}
