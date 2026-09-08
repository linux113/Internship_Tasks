import '../../../../config.dart';

class CustomRangeSlider extends StatelessWidget {
  const CustomRangeSlider({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (filterCtrl) {
      return SliderTheme(
        data: SliderThemeData(
            activeTrackColor: filterCtrl.appCtrl.appTheme.primary,
            inactiveTrackColor: filterCtrl.appCtrl.appTheme.lightGray,
            activeTickMarkColor: filterCtrl.appCtrl.appTheme.primary,
            inactiveTickMarkColor: filterCtrl.appCtrl.appTheme.lightGray,
            valueIndicatorColor: filterCtrl.appCtrl.appTheme.primary,
            valueIndicatorShape: const RectangularSliderValueIndicatorShape(),
            valueIndicatorTextStyle:
                TextStyle(color: filterCtrl.appCtrl.appTheme.white),
            rangeThumbShape: CustomThumbShape(),
            trackHeight: 5.0,
            showValueIndicator: ShowValueIndicator.never),
        child: RangeSlider(
          values: filterCtrl.currentRangeValues,
          min: 0,
          // 08/09: ab DYNAMIC — visible catalog ki max price (pehle fixed
          // 300 + divisions 6 = sirf 0/50/100..300 pe rukta tha; 25-65 AED
          // ki books ke liye slider ka 80% area bekaar tha). 10-AED steps
          // me smooth selection.
          max: filterCtrl.maxPriceVal,
          divisions: (filterCtrl.maxPriceVal / 10).round().clamp(10, 60),
          onChanged: (RangeValues values) {
            filterCtrl.currentRangeValues = values;
            filterCtrl.update();
          },
        ),
      );
    });
  }
}
