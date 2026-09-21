import '../../config.dart';
import 'package:multikart/controllers/home_product_controllers/cart_controller.dart';
import 'package:multikart/controllers/home_product_controllers/wishlist_controller.dart';
import 'package:multikart/widgets/common_image/count_badge.dart';

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
            // 17/09 (Lalit): fav icon ke upar SAVED count ka red badge —
            // wishlist badalte hi turant update (GetBuilder se).
            (Get.isRegistered<WishlistController>()
                    ? GetBuilder<WishlistController>(
                        builder: (wc) => CountBadge.wrap(
                            HeartIcon(color: appCtrl.appTheme.blackColor),
                            wc.wishlistCount))
                    // 21/09 (point 6): controller na ho to bhi badge STOARGE
                    // ke asli count ke saath dikhe — plain icon (bina count)
                    // kabhi NAHI.
                    : CountBadge.wrap(
                        HeartIcon(color: appCtrl.appTheme.blackColor),
                        WishlistController.loadWishlistItems().length))
                .gestures(onTap: () {
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
            // 17/09 (Lalit): cart icon ke upar QTY ka red badge — cart badalte
            // hi turant update (GetBuilder se; qty ka YOG dikhta hai).
            (Get.isRegistered<CartController>()
                    ? GetBuilder<CartController>(
                        builder: (cc) =>
                            CountBadge.wrap(const BuyIcon(), cc.cartItemsCount))
                    : const BuyIcon())
                .paddingSymmetric(
                horizontal: AppScreenUtil().screenWidth(15),
                vertical: AppScreenUtil().screenHeight(15)),
        ],
      );
    });
  }
}
