import '../../../../config.dart';

/// ORDER TRACKING timeline — Issue #3 (10/09 — "sequence of order tracking
/// is wrong"): pehle ye view AppArray().orderTrack ka STATIC demo data
/// dikhata tha (Out For Delivery sabse UPAR, Ordered sabse NEECHY — ulta
/// flow, aur fake dates "21/05/2020" tak). Controller REAL timeline banana
/// chuka tha (server GetOrderStatus + activities) par view usse jooda hi
/// nahi tha. Ab view sirf `orderDetailCtrl.timeline` dikhata hai:
/// chronological (Pending/Placed -> Processing -> Shipped -> Out for
/// delivery -> Delivered), har step ka translated canonical label,
/// done steps green, aane wale muted, cancelled RED terminal.
class OrderTimeLineProcess extends StatelessWidget {
  const OrderTimeLineProcess({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderDetailController>(builder: (orderDetailCtrl) {
      final steps = orderDetailCtrl.timeline;
      if (steps.isEmpty) {
        return const SizedBox.shrink();
      }
      final appCtrl = orderDetailCtrl.appCtrl;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < steps.length; i++)
            _TrackingRow(
              step: steps[i],
              isFirst: i == 0,
              isLast: i == steps.length - 1,
              prevDone: i > 0 ? (steps[i - 1]['done'] == true) : false,
              appCtrl: appCtrl,
            ),
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(20));
    });
  }
}

class _TrackingRow extends StatelessWidget {
  final Map<String, dynamic> step;
  final bool isFirst;
  final bool isLast;
  final bool prevDone;
  final AppController appCtrl;

  const _TrackingRow({
    Key? key,
    required this.step,
    required this.isFirst,
    required this.isLast,
    required this.prevDone,
    required this.appCtrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final done = step['done'] == true;
    final isCancelled = (step['key'] ?? '') == 'cancelled';
    final key = (step['key'] ?? '').toString();
    final rawName = (step['name'] ?? '').toString();
    // canonical key ho to translated label (4 languages), warna server ka
    // raw naam jaisa-hai (English ho sakta hai — server data hi sach hai)
    final title = key.isNotEmpty ? key.tr : rawName;
    final date = (step['date'] ?? '').toString();
    final note = (step['note'] ?? '').toString();

    final dotColor = isCancelled
        ? Colors.red
        : (done ? appCtrl.appTheme.primary : appCtrl.appTheme.borderColor);
    final textColor = isCancelled
        ? Colors.red
        : (done ? appCtrl.appTheme.blackColor : appCtrl.appTheme.contentColor);
    // upar wali line tabhi green jab UPAR ka step done ho (ordered se
    // delivered tak ka real progression)
    final topLineColor =
        (!isFirst && prevDone) ? appCtrl.appTheme.primary : appCtrl.appTheme.borderColor;
    final bottomLineColor = done && !isLast
        ? appCtrl.appTheme.primary
        : appCtrl.appTheme.borderColor;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- left rail: dot + connectors ----
          SizedBox(
            width: AppScreenUtil().screenWidth(24),
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: AppScreenUtil().screenHeight(14),
                  color: isFirst
                      ? Colors.transparent
                      : topLineColor,
                ),
                Container(
                  width: AppScreenUtil().size(16),
                  height: AppScreenUtil().size(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done ? dotColor : appCtrl.appTheme.whiteColor,
                    border: Border.all(color: dotColor, width: 2.5),
                  ),
                  child: done
                      ? Icon(Icons.check,
                          size: AppScreenUtil().size(9),
                          color: appCtrl.appTheme.whiteColor)
                      : null,
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast
                        ? Colors.transparent
                        : bottomLineColor,
                  ),
                ),
              ],
            ),
          ),
          const Space(12, 0),
          // ---- content ----
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AppScreenUtil().screenHeight(10)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Insets.i10, vertical: Insets.i5),
                  decoration: BoxDecoration(
                      color: appCtrl.appTheme.greyLight25,
                      borderRadius: BorderRadius.circular(50)),
                  child: LatoFontStyle(
                    text: title,
                    fontSize: FontSizes.f14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                if (date.isNotEmpty)
                  LatoFontStyle(
                    text: date,
                    fontSize: FontSizes.f14,
                    color: appCtrl.appTheme.contentColor,
                  ).paddingOnly(top: Insets.i10),
                if (note.isNotEmpty)
                  LatoFontStyle(
                    text: note,
                    fontSize: FontSizes.f12,
                    color: appCtrl.appTheme.contentColor,
                  ).paddingOnly(top: Insets.i5),
                if (!isLast) SizedBox(height: AppScreenUtil().screenHeight(14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
