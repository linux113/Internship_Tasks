import '../../config.dart';

class BuyIcon extends StatelessWidget {
  final Color? color;
  const BuyIcon({Key? key,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return SvgPicture.asset(
          svgAssets.buy,
          colorFilter: ColorFilter.mode(
              color ?? appCtrl.appTheme.blackColor, BlendMode.srcIn),
        ).gestures(onTap: () {
          // FIX: pehle Get.toNamed(dashboard) stack ke upar naya dashboard
          // push kar deta tha (back dabane par ajeeb navigation) — ab pehle
          // dashboard tak pop karke cart tab (2) select karte hai.
          appCtrl.selectedIndex = 2;
          appCtrl.isHeart = true;
          appCtrl.isCart = false;
          appCtrl.isShare = false;
          appCtrl.isSearch = false;
          appCtrl.isNotification = false;
          Get.until((route) =>
              route.settings.name == routeName.dashboard || route.isFirst);
          appCtrl.update();
          Get.forceAppUpdate();
        });
      }
    );
  }
}
