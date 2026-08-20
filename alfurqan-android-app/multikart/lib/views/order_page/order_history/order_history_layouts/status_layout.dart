import '../../../../config.dart';

class StatusLayout extends StatelessWidget {
  final String? title;
  const StatusLayout({Key? key,this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return CustomButton(
            padding: 0,
            margin: 0,
            height: AppScreenUtil().screenHeight(20),
            width: AppScreenUtil().screenWidth(75),
            title: title!,
            color: appCtrl.appTheme.greyLight25,
            fontSize: FontSizes.f8,
            fontColor: appCtrl.appTheme.blackColor,
            fontWeight: FontWeight.w700);
      }
    );
  }
}
