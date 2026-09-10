import '../../config.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      // 10/09 (user request): icon WAPAS purana simple magnifier — green box
      // NAHI chahiye tha, uska asli point icons row ka SPACE sahi hona tha
      // (wo AppBarActionLayout ke equal padding se pehle hi fix ho chuka).
      // BUG remains fixed: tap karte hi pahle selectedIndex=1 karke bottom-nav
      // chupke se CATEGORY tab par jump karta tha — ab nahi karta; seedha
      // REAL search page khulta hai, wapas aane par wahi tab.
      return SvgPicture.asset(
        svgAssets.search,
        fit: BoxFit.contain,
        height: AppScreenUtil().size(20),
        colorFilter:
            ColorFilter.mode(appCtrl.appTheme.blackColor, BlendMode.srcIn),
      ).gestures(onTap: () {
        Get.toNamed(routeName.search);
      });
    });
  }
}
