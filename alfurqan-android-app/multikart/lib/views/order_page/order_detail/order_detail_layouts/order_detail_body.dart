import '../../../../config.dart';

/// ORDER DETAIL BODY — pehle pura STATIC tha (fake items, fake timeline,
/// demo address, cartList price). Ab OrderDetailController ke REAL
/// GetOrder data se render hota hai.
class OrderDetailBody extends StatelessWidget {
  const OrderDetailBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailController>(builder: (ctrl) {
      final appCtrl = ctrl.appCtrl;

      // -------- loading --------
      if (ctrl.isLoading) {
        return SizedBox(
          height: AppScreenUtil().screenHeight(300),
          child: Center(
            child: CircularProgressIndicator(color: appCtrl.appTheme.primary),
          ),
        );
      }

      // -------- failed / no order --------
      if (ctrl.loadFailed) {
        return Column(children: [
          const Space(0, 60),
          LatoFontStyle(
              text: "Order detail load nahi ho paya",
              color: appCtrl.appTheme.contentColor,
              fontSize: FontSizes.f14),
          const Space(0, 15),
          LatoFontStyle(
                  text: "Retry",
                  color: appCtrl.appTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: FontSizes.f14)
              .gestures(onTap: () => ctrl.fetchOrderDetail()),
          const Space(0, 60),
        ]);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ================= header =================
          LatoFontStyle(
              text: "Order #${ctrl.orderNumber.isNotEmpty ? ctrl.orderNumber : ctrl.orderId}",
              fontWeight: FontWeight.w700,
              fontSize: FontSizes.f16,
              color: appCtrl.appTheme.blackColor),
          const Space(0, 5),
          if (ctrl.orderDate.isNotEmpty)
            LatoFontStyle(
                text: ctrl.orderDate,
                fontSize: FontSizes.f12,
                color: appCtrl.appTheme.contentColor),
          const Space(0, 10),
          if (ctrl.status.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppScreenUtil().screenWidth(10),
                  vertical: AppScreenUtil().screenHeight(4)),
              decoration: BoxDecoration(
                  color: appCtrl.appTheme.greyLight25,
                  borderRadius:
                      BorderRadius.circular(AppScreenUtil().borderRadius(5))),
              child: LatoFontStyle(
                  text: ctrl.status,
                  fontSize: FontSizes.f12,
                  fontWeight: FontWeight.w600,
                  color: appCtrl.appTheme.primary),
            ),
          const Space(0, 25),
          const BorderLineLayout(),
          const Space(0, 20),

          // ================= items =================
          ...ctrl.items.map((it) {
            return Padding(
              padding:
                  EdgeInsets.only(bottom: AppScreenUtil().screenHeight(15)),
              child: Row(children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppScreenUtil().borderRadius(8)),
                  child: imageNetwork(
                      url: (it['image'] ?? '').toString(),
                      width: AppScreenUtil().screenWidth(55),
                      height: AppScreenUtil().screenHeight(55),
                      fit: BoxFit.cover),
                ),
                const Space(10, 0),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LatoFontStyle(
                            text: (it['name'] ?? '').toString(),
                            fontSize: FontSizes.f13,
                            fontWeight: FontWeight.w600,
                            color: appCtrl.appTheme.blackColor),
                        const Space(0, 4),
                        LatoFontStyle(
                            text:
                                "Qty ${it['qty']} × ${appCtrl.priceSymbol}${((it['price'] as num) * appCtrl.rateValue).toStringAsFixed(2)}",
                            fontSize: FontSizes.f12,
                            color: appCtrl.appTheme.contentColor),
                      ]),
                ),
                LatoFontStyle(
                    text:
                        "${appCtrl.priceSymbol}${((it['lineTotal'] as num) * appCtrl.rateValue).toStringAsFixed(2)}",
                    fontSize: FontSizes.f13,
                    fontWeight: FontWeight.w700,
                    color: appCtrl.appTheme.blackColor),
              ]),
            );
          }),
          if (ctrl.items.isNotEmpty) ...[
            const Space(0, 10),
            const BorderLineLayout(),
            const Space(0, 20),
          ],

          // ================= timeline =================
          if (ctrl.timeline.isNotEmpty) ...[
            LatoFontStyle(
                text: "Order Tracking",
                fontSize: FontSizes.f15,
                fontWeight: FontWeight.w700,
                color: appCtrl.appTheme.blackColor),
            const Space(0, 15),
            ...ctrl.timeline.asMap().entries.map((e) {
              final t = e.value;
              final isLast = e.key == ctrl.timeline.length - 1;
              return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(children: [
                      Container(
                          width: AppScreenUtil().size(10),
                          height: AppScreenUtil().size(10),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: appCtrl.appTheme.primary)),
                      if (!isLast)
                        Container(
                            width: 1,
                            height: AppScreenUtil().screenHeight(28),
                            color: appCtrl.appTheme.gray),
                    ]),
                    const Space(10, 0),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LatoFontStyle(
                                text: (t['name'] ?? '').toString(),
                                fontSize: FontSizes.f13,
                                fontWeight: FontWeight.w600,
                                color: appCtrl.appTheme.blackColor),
                            if (((t['date'] ?? '') as String).isNotEmpty)
                              LatoFontStyle(
                                  text: (t['date'] ?? '').toString(),
                                  fontSize: FontSizes.f11,
                                  color: appCtrl.appTheme.contentColor),
                            if (((t['note'] ?? '') as String).isNotEmpty)
                              LatoFontStyle(
                                  text: (t['note'] ?? '').toString(),
                                  fontSize: FontSizes.f11,
                                  overflow: TextOverflow.clip,
                                  color: appCtrl.appTheme.contentColor),
                            const Space(0, 10),
                          ]),
                    )
                  ]);
            }),
            const Space(0, 10),
            const BorderLineLayout(),
            const Space(0, 20),
          ],

          // ================= address =================
          if (ctrl.address.isNotEmpty) ...[
            LatoFontStyle(
                text: "Shipping Details",
                fontSize: FontSizes.f15,
                fontWeight: FontWeight.w700,
                color: appCtrl.appTheme.blackColor),
            const Space(0, 10),
            LatoFontStyle(
                text: [
                  ctrl.address['name'],
                  ctrl.address['line1'],
                  [ctrl.address['city'], ctrl.address['state']]
                      .where((e) => (e ?? '').toString().isNotEmpty)
                      .join(', '),
                  ctrl.address['country'],
                ]
                    .where((e) => (e ?? '').toString().isNotEmpty)
                    .join('\n'),
                fontSize: FontSizes.f13,
                overflow: TextOverflow.clip,
                color: appCtrl.appTheme.contentColor),
            if ((ctrl.address['phone'] ?? '').toString().isNotEmpty) ...[
              const Space(0, 5),
              LatoFontStyle(
                  text: "Phone: ${ctrl.address['phone']}",
                  fontSize: FontSizes.f13,
                  color: appCtrl.appTheme.contentColor),
            ],
            const Space(0, 20),
            const BorderLineLayout(),
            const Space(0, 20),
          ],

          // ================= price details =================
          LatoFontStyle(
              text: "Price Details",
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
              color: appCtrl.appTheme.blackColor),
          const Space(0, 12),
          _priceRow(appCtrl, "Subtotal", ctrl.subtotal),
          if (ctrl.shipping > 0) _priceRow(appCtrl, "Shipping", ctrl.shipping),
          if (ctrl.discount > 0)
            _priceRow(appCtrl, "Discount", -ctrl.discount),
          if (ctrl.tax > 0) _priceRow(appCtrl, "Tax", ctrl.tax),
          const Space(0, 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            LatoFontStyle(
                text: "Total",
                fontSize: FontSizes.f15,
                fontWeight: FontWeight.w700,
                color: appCtrl.appTheme.blackColor),
            LatoFontStyle(
                text: "${appCtrl.priceSymbol}${(ctrl.total * appCtrl.rateValue).toStringAsFixed(2)}",
                fontSize: FontSizes.f15,
                fontWeight: FontWeight.w700,
                color: appCtrl.appTheme.primary),
          ]),
          const Space(0, 40),
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }

  Widget _priceRow(AppController appCtrl, String title, double val) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppScreenUtil().screenHeight(6)),
      child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        LatoFontStyle(
            text: title,
            fontSize: FontSizes.f13,
            color: appCtrl.appTheme.contentColor),
        LatoFontStyle(
            text: "${appCtrl.priceSymbol}${(val * appCtrl.rateValue).toStringAsFixed(2)}",
            fontSize: FontSizes.f13,
            color: appCtrl.appTheme.blackColor),
      ]),
    );
  }
}
