import '../../config.dart';

class AppBarActionLayout extends StatelessWidget {
  const AppBarActionLayout({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Row(
        children: [
          if (appCtrl.isShare)
            const ShareIcon()
                .paddingSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          if (appCtrl.isSearch)
            const SearchIcon().paddingSymmetric(
                horizontal: AppScreenUtil().screenWidth(appCtrl.isSearch
                    ? appCtrl.isNotification
                        ? 0
                        : 10
                    : 10)),
          // HIDE (user request): bell/notification icon ab app bar me NAHI
          // dikhega (notifications page abhi backend API ke bina static thi).
          if (appCtrl.isHeart)
            HeartIcon(
              color: appCtrl.appTheme.blackColor,
            ).gestures(onTap: () {
              // FIX: pehle Get.toNamed(dashboard) se current stack ke UPAR ek
              // naya dashboard push ho jata tha — isliye (1) wishlist dikhte
              // hi lagta tha par kaam nahi karta tha, (2) back dabane par
              // dashboard ke andar dashboard aate rehte the.
              // Ab stack ko pehle dashboard tak WAPAS pop karo, phir
              // wishlist tab (3) select karo.
              appCtrl.selectedIndex = 3;
              appCtrl.isHeart = false;
              appCtrl.isCart = true;
              appCtrl.isShare = false;
              appCtrl.isSearch = false;
              appCtrl.isNotification = false;
              Get.until((route) =>
                  route.settings.name == routeName.dashboard || route.isFirst);
              appCtrl.update();
              Get.forceAppUpdate();
            }).paddingSymmetric(
                // FIX (user report): bell icon hatte hi Heart ka padding 0
                // ho jata tha — Search aur Heart ek dusre se CHIPKE hue
                // dikhte the. Ab hamesha 10 gap rahega.
                horizontal: AppScreenUtil().screenWidth(10)),
          if (appCtrl.isCart)
            const BuyIcon().paddingSymmetric(
                horizontal: AppScreenUtil().screenWidth(15),
                vertical: AppScreenUtil().screenHeight(15)),
        ],
      );
    });
  }
}
