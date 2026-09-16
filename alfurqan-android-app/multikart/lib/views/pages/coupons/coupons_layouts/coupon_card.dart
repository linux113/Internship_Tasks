import '../../../../config.dart';

class CouponCard extends StatelessWidget {
  final CouponModel? couponModel;
  final int? index, lastIndex;

  const CouponCard({Key? key, this.couponModel, this.index, this.lastIndex})
      : super(key: key);

  /// 15/09 (point 4): coupon ki REAL terms backend payload se line banao —
  /// minimum order / validity window / first-order only. Pehle yaha hamesha
  /// ek DEAD "View T&C" text dikhta tha (tap bhi nahi hota tha) — usko
  /// hata kar asli terms hi inline likh di. Terms na ho to line chhupi.
  List<String> _termsOf(CouponModel c) {
    final parts = <String>[];
    String two(num v) => v.toStringAsFixed(v % 1 == 0 ? 0 : 2);
    if (c.minSpend != null && c.minSpend! > 0) {
      parts.add('${'couponMinOrder'.tr}: AED ${two(c.minSpend!)}');
    }
    if (c.endsAt != null) {
      final e = c.endsAt!;
      parts.add(
          '${'validTill'.tr} ${e.year.toString().padLeft(4, '0')}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}');
    }
    if (c.isFirstOrder) parts.add('firstOrderOnly'.tr);
    return parts;
  }

  bool _isExpired(CouponModel c) {
    if (c.endsAt == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return DateTime(c.endsAt!.year, c.endsAt!.month, c.endsAt!.day)
        .isBefore(today);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      // point 2 (15/09): active coupon ke card par APPLY ki jagah
      // "Applied" (disabled) + REMOVE button dikhta hai.
      return GetBuilder<CouponsController>(builder: (couponsCtrl) {
        final c = couponModel!;
        final active = couponsCtrl.isActive(c.code);
        final expired = _isExpired(c);
        final terms = _termsOf(c);
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                LatoFontStyle(
                    text: c.code,
                    fontSize: FontSizes.f14,
                    color: appCtrl.appTheme.blackColor,
                    fontWeight: FontWeight.w600),
                CouponTitle(
                  title: c.title,
                ),
              ],
            ),
            if (active)
              Row(children: [
                LatoFontStyle(
                    text: 'applied'.tr,
                    color: appCtrl.appTheme.greenColor,
                    fontSize: FontSizes.f14,
                    fontWeight: FontWeight.w600),
                const Space(12, 0),
                LatoFontStyle(
                        text: 'remove'.tr,
                        color: appCtrl.appTheme.primary,
                        fontSize: FontSizes.f14,
                        fontWeight: FontWeight.w600)
                    .gestures(onTap: () {
                  couponsCtrl.removeCode(c.code ?? '');
                })
              ])
            else
              LatoFontStyle(
                      text: CouponFont().apply,
                      color: expired
                          ? appCtrl.appTheme.contentColor
                          : appCtrl.appTheme.primary,
                      fontSize: FontSizes.f14,
                      fontWeight: FontWeight.w600)
                  .gestures(onTap: () {
                // expired par bhi tap = saaf toast (couponExpired) — apply
                // gate controller me hi hai; expire ho to apply nahi hoga.
                couponsCtrl.applyCode(c.code ?? '');
              })
          ]),
          const Space(0, 12),
          LatoFontStyle(
              text: c.description,
              overflow: TextOverflow.clip,
              color: appCtrl.appTheme.contentColor,
              fontSize: FontSizes.f12),
          if (terms.isNotEmpty) ...[
            const Space(0, 8),
            LatoFontStyle(
                text: terms.join('  •  '),
                overflow: TextOverflow.clip,
                color: expired
                    ? appCtrl.appTheme.primary
                    : appCtrl.appTheme.contentColor,
                fontSize: FontSizes.f11),
          ],
          const Space(0, 15),
          if (index != lastIndex)
            Divider(
              color: appCtrl.appTheme.greyLight25,
            )
        ])
            .marginOnly(bottom: AppScreenUtil().screenHeight(10))
            .marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
      });
    });
  }
}
