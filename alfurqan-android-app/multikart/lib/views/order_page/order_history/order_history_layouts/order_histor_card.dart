import '../../../../config.dart';

/// ORDER HISTORY CARD — 21/09 FINAL DESIGN (Lalit points 4 & 5):
///  4) List me product PHOTO ki jagah ORDER NUMBER dikhe; photo/items ka
///     poora detail CLICK kholne par andar wali screen me (detail page).
///  5) Ek order me kitne bhi products ho — list me wo order SIRF EK baar
///     dikhe (pehle har product ka alag row ban jata tha, list clutter).
///
/// Card = grey strip (Ordered date + Delivery status) + EK compact row:
///  [green #N tile] | Order #N · Total · N items | STATUS chip
/// Tap = detail (summary prefill wahi hai — items/photo detail page par).
class OrderHistoryCard extends StatelessWidget {
  final OrderHistoryModel? orderHistoryModel;
  final int? index, lastIndex;
  final GestureTapCallback? onTap;
  const OrderHistoryCard(
      {Key? key, this.orderHistoryModel, this.index, this.lastIndex, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      final order = orderHistoryModel!;
      final rows = order.daysWiseList ?? const <DaysWiseList>[];
      final first = rows.isNotEmpty ? rows.first : null;
      // REAL total (first row ke 'size' me RAW AED string) + REAL item
      // count (slim row ke products count = daysWise rows; placeholder
      // order ke liye 1). Dono server data se — koi guess nahi.
      final total =
          double.tryParse(first?.size ?? '') ?? 0;
      final itemCount = rows.isNotEmpty ? rows.length : 1;
      final rawStatus = first?.status ?? '';
      return InkWell(
        // REAL order id + SUMMARY dono bhejo — pehle inner InkWell sirf id
        // bhejta tha (outer .gestures wala summary gesture-arena me haar
        // jata tha), jisse detail page ka prefill kabhi chalta hi nahi tha
        // aur api fail par user ko KHAALI page dikhta tha.
        onTap: () => Get.toNamed(routeName.orderDetail, arguments: {
          'id': order.orderId ?? 0,
          'summary': order,
        }),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LatoFontStyle(
              text: order.orderDay.toString().tr,
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor,
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
            const Space(0, 12),
            // ---- Ordered date + Delivery status (grey strip) ----
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
                        value: first?.date ?? ''),
                    if ((first?.deliveryStatus ?? '').isNotEmpty) ...[
                      const Space(15, 0),
                      OrderDateDeliveryStatus(
                          title: OrderHistoryFont().deliveryStatus,
                          value: (first?.deliveryStatus ?? '').tr)
                    ]
                  ]),
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
            const Space(0, 10),
            // ---- EK compact row per ORDER: [ #N ]  Order #N · items ----
            Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(children: [
                      // ORDER NUMBER TILE (photo ki jagah — point 4)
                      Container(
                        height: AppScreenUtil().screenHeight(48),
                        width: AppScreenUtil().screenHeight(48),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                AppScreenUtil().borderRadius(10)),
                            border: Border.all(
                                color: appCtrl.appTheme.primary
                                    .withOpacity(.55)),
                            color:
                                appCtrl.appTheme.primary.withOpacity(.08)),
                        child: Text(
                          '#${order.orderId ?? ''}',
                          style: TextStyle(
                              color: appCtrl.appTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: FontSizes.f12),
                        ),
                      ),
                      const Space(12, 0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LatoFontStyle(
                                text: "Order #${order.orderId ?? ''}",
                                fontWeight: FontWeight.w700,
                                fontSize: FontSizes.f14,
                                color: appCtrl.appTheme.blackColor),
                            const Space(0, 4),
                            Row(children: [
                              // REAL TOTAL (RAW AED * rateValue — purana
                              // convention hi hai)
                              if (total > 0) ...[
                                LatoFontStyle(
                                    text: "totalLabel".tr,
                                    fontSize: FontSizes.f12,
                                    color:
                                        appCtrl.appTheme.contentColor),
                                const Space(5, 0),
                                LatoFontStyle(
                                    text:
                                        "${appCtrl.priceSymbol}${(total * appCtrl.rateValue).toStringAsFixed(2)}",
                                    fontSize: FontSizes.f12,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        appCtrl.appTheme.blackColor),
                                const Space(10, 0),
                              ],
                              // REAL item count (ek order me "N items")
                              LatoFontStyle(
                                  text:
                                      "$itemCount ${'items'.tr}",
                                  fontSize: FontSizes.f12,
                                  color: appCtrl.appTheme.contentColor),
                            ]),
                            const Space(0, 6),
                            LatoFontStyle(
                                text: 'viewDetails'.tr,
                                fontSize: FontSizes.f12,
                                fontWeight: FontWeight.w600,
                                color: appCtrl.appTheme.primary),
                          ],
                        ),
                      ),
                    ]),
                  ),
                  // status khaali ho to KHAALI grey pill mat dikhao
                  if (rawStatus.isNotEmpty)
                    StatusLayout(
                        title: OrderDetailController
                                .canonStatusKey(rawStatus)
                                .isNotEmpty
                            ? OrderDetailController
                                    .canonStatusKey(rawStatus)
                                    .tr
                                    .toUpperCase()
                            : rawStatus.tr.toUpperCase())
                ]).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
            const Space(0, 20),
            if (index != lastIndex) const BorderLineLayout(),
            const Space(0, 15),
          ],
        ),
      );
    });
  }
}
