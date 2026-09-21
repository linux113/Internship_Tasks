import '../../config.dart';
import 'package:multikart/controllers/home_product_controllers/cart_controller.dart';
import 'package:multikart/controllers/home_product_controllers/wishlist_controller.dart';

class CommonBottomNavigation extends StatelessWidget {
  final ValueChanged<int>? onTap;

  const CommonBottomNavigation({Key? key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 17/09 (Lalit): bottom nav CART (index 2) / WISHLIST (index 3) icons
    // par live count badges — cart ya wishlist badalte hi badge turant
    // badle, isliye un controller ke GetBuilder ke ANDAR wrap karte hai
    // (registered na ho to plain bar — splash jaise screens safe).
    return GetBuilder<AppController>(builder: (appCtrl) {
      Widget navBar() => Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              unselectedItemColor: appCtrl.appTheme.blackColor,
              showUnselectedLabels: true,
              selectedFontSize: 12,
              unselectedFontSize: 10,
              backgroundColor: appCtrl.appTheme.whiteColor,
              selectedItemColor: appCtrl.appTheme.primary,
              items: [
                ...appCtrl.bottomList.asMap().entries.map((e) {
                  var badgeCount = 0;
                  if (e.key == 2 && Get.isRegistered<CartController>()) {
                    badgeCount = Get.find<CartController>().cartItemsCount;
                  } else if (e.key == 3) {
                    // 21/09 (point 6): controller kisi wajah se abhi na bana
                    // ho to bhi badge 0 mat dikhayo — storage ka ASLI count.
                    badgeCount = Get.isRegistered<WishlistController>()
                        ? Get.find<WishlistController>().wishlistCount
                        : WishlistController.loadWishlistItems().length;
                  }
                  return BottomNavigationWidget().bottomNavigationCard(
                      color: appCtrl.selectedIndex == e.key
                          ? appCtrl.appTheme.primary
                          : appCtrl.appTheme.blackColor,
                      selectedIndex: appCtrl.selectedIndex,
                      bgColor: appCtrl.appTheme.whiteColor,
                      image: appCtrl.selectedIndex == e.key
                          ? e.value['selectedIcon']
                          : e.value['unSelectedIcon'],
                      title: e.value['title'].toString().tr.toUpperCase(),
                      badgeCount: badgeCount);
                }).toList()
              ],
              currentIndex: appCtrl.selectedIndex,
              onTap: onTap,
            ),
          );

      // Builder-chain: jo controller registered hai uska listener bar ko
      // rebuild karwayega jab uska data badlega (badge count ke liye).
      Widget Function() buildNav = navBar;
      if (Get.isRegistered<CartController>()) {
        final inner = buildNav;
        buildNav =
            () => GetBuilder<CartController>(builder: (_) => inner());
      }
      if (Get.isRegistered<WishlistController>()) {
        final inner = buildNav;
        buildNav =
            () => GetBuilder<WishlistController>(builder: (_) => inner());
      }
      return buildNav();
    });
  }
}
