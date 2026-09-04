import '../../../../config.dart';

class OrderDaysWise extends StatelessWidget {
  final DaysWiseList? daysWiseList;
  final int? index, lastIndex;
  final bool isRatingShow;
  final GestureTapCallback? onTap;

  const OrderDaysWise(
      {Key? key,
      this.daysWiseList,
      this.lastIndex,
      this.index,
      this.onTap,
      this.isRatingShow = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OrderHistoryWidget().imageLayout(daysWiseList!.image),
                  OrderHistorySizeQty(daysWiseList: daysWiseList)
                ],
              ),
              // status khaali ho to KHAALI grey pill mat dikhao (screenshot
              // me top-right empty rounded box dikhta tha)
              if ((daysWiseList!.status ?? '').isNotEmpty)
                StatusLayout(title: daysWiseList!.status!.tr.toUpperCase())
            ]).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
        const Space(0, 20),
        // FIX (user screenshot): pehle yaha STATIC template MAP image
        // (UNC Charlotte wala naksha!) dikhata tha — kisi real data se
        // connected nahi tha. Ab plain card par Ordered date + (ho to)
        // Delivery status — server slim rows me status nahi aata, tab woh
        // column hide (khaali "Delivery Status:" label nahi).
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: AppScreenUtil().screenWidth(12),
              vertical: AppScreenUtil().screenHeight(10)),
          decoration: BoxDecoration(
              color: appCtrl.appTheme.greyLight25,
              borderRadius:
                  BorderRadius.circular(AppScreenUtil().borderRadius(8))),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OrderDateDeliveryStatus(
                    title: OrderHistoryFont().ordered,
                    value: daysWiseList!.date),
                if ((daysWiseList!.deliveryStatus ?? '').isNotEmpty) ...[
                  const Space(15, 0),
                  OrderDateDeliveryStatus(
                      title: OrderHistoryFont().deliveryStatus,
                      value: daysWiseList!.deliveryStatus!.tr)
                ]
              ]),
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
        if (isRatingShow) OrderRating(onTap: onTap),
        const Space(0, 15),
        if (index != lastIndex)
          Divider(
              color: appCtrl.appTheme.borderColor,
              endIndent: 15,
              indent: 15,
              thickness: 1),
        const Space(0, 15)
      ]);
    });
  }
}
