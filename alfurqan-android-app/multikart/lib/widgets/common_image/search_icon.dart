import '../../config.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return SvgPicture.asset(
        svgAssets.search,
        fit: BoxFit.contain,
        height: AppScreenUtil().size(20),
        colorFilter:
            ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn),
      ).gestures(onTap: () {
        appCtrl.selectedIndex = 1;
        appCtrl.update();
        Get.forceAppUpdate();
        Get.toNamed(routeName.search);
      });
    });
  }
}
