import '../../../../../config.dart';

class PriceLayout extends StatelessWidget {
  final String? totalPrice,mrp, discount;
  final bool isDiscountShow;
  final bool isBold;
  final double fontSize;
  const PriceLayout({Key? key,this.discount,this.mrp,this.totalPrice,this.isDiscountShow = true,this.isBold = true,this.fontSize = FontSizes.f12}) : super(key: key);

  /// "AED 90.00" jaise string se sirf number nikalo (compare karne ke liye).
  static double? _numOf(String? s) {
    if (s == null) return null;
    return double.tryParse(s.replaceAll(RegExp('[^0-9.]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<AppController>(
      builder: (appCtrl) {
        final double? selling = _numOf(mrp);
        final double? original = _numOf(totalPrice);
        // FIX: struck-through original SIRF tab dikhao jab wo selling se zyada ho
        // (pehle "AED 30.0 AED 30.00" do baar dikhta tha).
        final bool showStrike =
            original != null && selling != null && original > selling;
        // FIX: discount khaali ho to "( off)" text mat dikhao.
        final bool showOff = isDiscountShow &&
            discount != null &&
            discount!.trim().isNotEmpty;
        return FittedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LatoFontStyle(
                text: mrp,
                fontSize: fontSize,
                fontWeight:isBold ? FontWeight.w600 : FontWeight.normal,
                color: appCtrl.appTheme.blackColor,
              ),
              if (showStrike) ...[
                const Space(5, 0),
                LatoFontStyle(
                  text: totalPrice,
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: appCtrl.appTheme.contentColor,
                  textDecoration: TextDecoration.lineThrough,
                ),
              ],
              if (showOff) ...[
                const Space(5, 0),
                LatoFontStyle(
                  text: '($discount ${CommonTextFont().off})',
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
                  color: appCtrl.appTheme.primary,
                ),
              ],
            ],
          ).paddingOnly(left: AppScreenUtil().screenWidth(5)),
        );
      }
    );
  }
}
