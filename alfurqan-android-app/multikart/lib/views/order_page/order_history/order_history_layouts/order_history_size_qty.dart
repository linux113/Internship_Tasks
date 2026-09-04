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
          // "Size:" demo label hata diya — yeh field ab order ka REAL TOTAL
          // hai; currency symbol + rate conversion view par (server RAW AED
          // deta hai, INR select karne par ₹ me convert hoga).
          if ((daysWiseList!.size ?? '').isNotEmpty) ...[
            OrderHistoryWidget().commonText("totalLabel".tr),
            const Space(5, 0),
            OrderHistoryWidget().commonText(
                "${appCtrl.priceSymbol}${((double.tryParse(daysWiseList!.size ?? '') ?? 0) * appCtrl.rateValue).toStringAsFixed(2)}"),
            const Space(10, 0),
          ],
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
