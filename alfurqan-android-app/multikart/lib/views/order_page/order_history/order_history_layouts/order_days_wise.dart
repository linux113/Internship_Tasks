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
              StatusLayout(title: daysWiseList!.status!.tr.toUpperCase())
            ]).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
        const Space(0, 20),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Image.asset(imageAssets.mapSection,
                height: AppScreenUtil().screenHeight(100), fit: BoxFit.fill),
            Row(children: [
              OrderDateDeliveryStatus(
                  title: OrderHistoryFont().ordered, value: daysWiseList!.date),
              const Space(15, 0),
              OrderDateDeliveryStatus(
                  title: OrderHistoryFont().deliveryStatus,
                  value: daysWiseList!.deliveryStatus!.tr)
            ]).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15))
          ],
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
