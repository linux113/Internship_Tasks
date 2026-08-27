import '../../../../config.dart';

class ActionButton extends StatelessWidget {
  final int? index;
  final int? selectRadio;
  final String? text;
  final GestureTapCallback? onTap;

  const ActionButton(
      {Key? key, this.selectRadio, this.index, this.text, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: AppScreenUtil().screenWidth(10),
                  vertical: AppScreenUtil().screenHeight(6)),
              decoration: BoxDecoration(
                  color: index! == selectRadio
                      ? appCtrl.appTheme.whiteColor
                      : appCtrl.appTheme.greyLight25,
                  borderRadius:
                      BorderRadius.circular(AppScreenUtil().borderRadius(2))),
              child: LatoFontStyle(
                  text: text,
                  fontSize: FontSizes.f12,
                  color: appCtrl.appTheme.contentColor)),
        );
      },
    );
  }
}
