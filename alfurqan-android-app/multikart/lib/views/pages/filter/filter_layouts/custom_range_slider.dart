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
          max: 100,
          divisions: 10,
          onChanged: (RangeValues values) {
            filterCtrl.currentRangeValues = values;
            filterCtrl.update();
          },
        ),
      );
    });
  }
}
