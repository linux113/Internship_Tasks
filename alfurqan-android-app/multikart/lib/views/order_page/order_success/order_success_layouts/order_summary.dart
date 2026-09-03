import '../../../../config.dart';
import '../../../../controllers/checkout_controller/checkout_controller.dart';

/// ORDER SUMMARY (success page) — FIX (Issue #3): pehle yaha STATIC demo
/// "orderSummaryArray" ke FASHION CLOTHS + demo cartList ka fake summary
/// dikhta tha. Ab sirf WOH items dikhte hai jo user ne actually order kiye
/// (CheckoutController.lastPlacedOrder snapshot — cart clear hone se pehle
/// liya gaya).
class OrderSummary extends StatelessWidget {
  const OrderSummary({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      final order = CheckoutController.lastPlacedOrder;
      final List items =
          (order?['items'] is List) ? order!['items'] as List : const [];
      final String total = (order?['total'] ?? '0').toString();
      final double totalVal =
          double.tryParse(total.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LatoFontStyle(
                  text: OrderSuccessFont().orderSummary,
                  fontSize: FontSizes.f16,
                  color: appCtrl.appTheme.blackColor,
                  fontWeight: FontWeight.w700)
              .paddingSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          const Space(0, 15),

          // ---- REAL ordered items ----
          if (items.isEmpty)
            LatoFontStyle(
                    text: "Order placed successfully.",
                    fontSize: FontSizes.f13,
                    color: appCtrl.appTheme.contentColor)
                .paddingSymmetric(horizontal: AppScreenUtil().screenWidth(15))
          else
            ...items.map((e) {
              final m = e is Map ? e : const <String, dynamic>{};
              final double unit =
                  double.tryParse(m['price']?.toString() ?? '0') ?? 0;
              final int qty = int.tryParse(m['qty']?.toString() ?? '1') ?? 1;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: AppScreenUtil().screenHeight(12)),
                child: Row(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                        AppScreenUtil().borderRadius(8)),
                    child: imageNetwork(
                        url: (m['image'] ?? '').toString(),
                        width: AppScreenUtil().screenWidth(45),
                        height: AppScreenUtil().screenHeight(45),
                        fit: BoxFit.cover),
                  ),
                  const Space(10, 0),
                  Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LatoFontStyle(
                              text: (m['name'] ?? '').toString(),
                              fontSize: FontSizes.f13,
                              fontWeight: FontWeight.w600,
                              maxLines: 2,
                              color: appCtrl.appTheme.blackColor),
                          LatoFontStyle(
                              text:
                                  "Qty $qty × ${appCtrl.priceSymbol}${(unit * appCtrl.rateValue).toStringAsFixed(2)}",
                              fontSize: FontSizes.f12,
                              color: appCtrl.appTheme.contentColor),
                        ]),
                  ),
                  LatoFontStyle(
                      text:
                          "${appCtrl.priceSymbol}${(unit * qty * appCtrl.rateValue).toStringAsFixed(2)}",
                      fontSize: FontSizes.f13,
                      fontWeight: FontWeight.w700,
                      color: appCtrl.appTheme.blackColor),
                ]),
              );
            }).toList(),

          // ---- REAL total ----
          if (totalVal > 0) ...[
            const Space(0, 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LatoFontStyle(
                      text: "Total",
                      fontSize: FontSizes.f15,
                      fontWeight: FontWeight.w700,
                      color: appCtrl.appTheme.blackColor),
                  LatoFontStyle(
                      text:
                          "${appCtrl.priceSymbol}${(totalVal * appCtrl.rateValue).toStringAsFixed(2)}",
                      fontSize: FontSizes.f15,
                      fontWeight: FontWeight.w700,
                      color: appCtrl.appTheme.primary),
                ]).paddingSymmetric(
                horizontal: AppScreenUtil().screenWidth(15)),
          ],
          const Space(0, 20),
        ],
      )
          .width(MediaQuery.of(context).size.width)
          .marginSymmetric(vertical: AppScreenUtil().screenHeight(20));
    });
  }
}
