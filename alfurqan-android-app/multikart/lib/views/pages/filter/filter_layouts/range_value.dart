

import '../../../../config.dart';

class RangeValueLayout extends StatelessWidget {
  const RangeValueLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (filterCtrl) {
      // 08/09 DEEP-fix: pehle labels 45px FIXED boxes me fixed slots par
      // dikh te the — "AED300.0" clip hokar "AED3" dikhta tha (!) aur
      // slider ghumate hi label GAYAB ho jata tha (sirf 0/50/100... slots
      // ke exact match par dikhta tha). Ab LIVE values ke 2 saaf boxes —
      // hamesha dikhte hai, kabhi clip nahi hote.
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _priceBox(
              filterCtrl,
              '${filterCtrl.appCtrl.priceSymbol}${filterCtrl.currentRangeValues.start.round()}'),
          _priceBox(filterCtrl,
              '${filterCtrl.appCtrl.priceSymbol}${filterCtrl.currentRangeValues.end.round()}'),
        ],
      );
    });
  }

  Widget _priceBox(FilterController filterCtrl, String text) {
    return Container(
      decoration: BoxDecoration(
        // Brand green tint
        color: const Color(0xFF044015).withOpacity(.2),
        borderRadius:
            BorderRadius.circular(AppScreenUtil().borderRadius(5)),
      ),
      padding: EdgeInsets.symmetric(
          horizontal: AppScreenUtil().size(10),
          vertical: AppScreenUtil().size(5)),
      alignment: Alignment.center,
      child: LatoFontStyle(
        text: text,
        fontSize: FontSizes.f13,
        fontWeight: FontWeight.w600,
        color: filterCtrl.appCtrl.appTheme.blackColor,
      ),
    );
  }
}
