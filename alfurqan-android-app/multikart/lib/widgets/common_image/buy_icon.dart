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
        ).gestures(onTap: ()async{
          appCtrl.isShimmer = true;

          appCtrl.selectedIndex = 2;
          appCtrl.isHeart = true;
          appCtrl.isCart = false;
          appCtrl.isShare = false;
          appCtrl.isSearch = false;
          appCtrl.isNotification = false;
          Get.toNamed(routeName.dashboard);
          await Future.delayed(DurationsClass.s1);
          appCtrl.isShimmer = false;
          appCtrl.update();

          Get.forceAppUpdate();

        });
      }
    );
  }
}
