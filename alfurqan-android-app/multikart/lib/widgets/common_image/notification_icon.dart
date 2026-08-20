import '../../config.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return SvgPicture.asset(
          svgAssets.notification,

          colorFilter: ColorFilter.mode(
              appCtrl.appTheme.blackColor, BlendMode.srcIn),
          fit: BoxFit.contain,
          height: AppScreenUtil().size(20),
        ).gestures(onTap: ()=> Get.toNamed(routeName.notification));

      }
    );
  }
}
