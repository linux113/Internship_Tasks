import 'package:multikart/config.dart';

class Variants extends StatelessWidget {
  final GestureTapCallback? qtyTap, sizeTap;
  final bool isActionShow;
  final GestureTapCallback? firstActionTap;
  final GestureTapCallback? secondActionTap;

  /// Books store me Size/Qty ka matlab nahi — fake "Qty 1 / Size S"
  /// dropdowns hide karne ke liye false karo (actions row bhi rehti hai).
  final bool showVariantOptions;

  const Variants(
      {Key? key,
      this.sizeTap,
      this.qtyTap,
      this.isActionShow = false,
      this.firstActionTap,
      this.secondActionTap,
      this.showVariantOptions = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showVariantOptions) ...[
            Row(
              children: [
                VariantOptions(
                  text: "${CommonTextFont().qty} 1",
                  onTap: qtyTap,
                ),
                const Space(15, 0),
                VariantOptions(
                  text: "${CommonTextFont().size} S",
                  onTap: sizeTap,
                ),
              ],
            ),
            const Space(0, 15),
          ],
          Container(
            height: AppScreenUtil().screenHeight(0.5),
            color: appCtrl.appTheme.lightGray,
            width: MediaQuery.of(context).size.width / 1.8,
          ),
          const Space(0, 10),
          ActionLayout(
            firstActionIcon: HeartIcon(color: appCtrl.appTheme.blackColor)
                .height(AppScreenUtil().screenHeight(14)),
            firstActionName: CommonTextFont().moveToWishList,
            secondAction: CommonTextFont().remove,
            secondActionTap: secondActionTap,
            firstActionTap:  firstActionTap,
          )
        ],
      );
    });
  }
}
