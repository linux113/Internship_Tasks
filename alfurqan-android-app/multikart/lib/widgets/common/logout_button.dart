import '../../config.dart';
import '../../controllers/home_product_controllers/wishlist_controller.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return InkWell(
          onTap: () {
            showLogoutDialog(
              () async {
                appCtrl.selectedIndex = 0;
                // FIX: erase() await nahi ho raha tha — usse pehle hi login
                // page khul jata tha aur token kabhi-kabhi bacha rehta tha.
                await appCtrl.storage.erase();
                // Pichhle user ka cart/wishlist memory me pada rehta tha —
                // naye user ke login par purana data dikh sakta tha.
                if (Get.isRegistered<CartController>()) {
                  Get.delete<CartController>(force: true);
                }
                if (Get.isRegistered<WishlistController>()) {
                  Get.delete<WishlistController>(force: true);
                }
                Get.forceAppUpdate();
                Get.offAllNamed(routeName.login);
              },
            );
          },

          child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                  vertical: AppScreenUtil().screenHeight(10)),
              margin: EdgeInsets.symmetric(
                  horizontal: AppScreenUtil().screenWidth(15),
                  vertical: AppScreenUtil().screenHeight(15)),
              decoration: BoxDecoration(
                  border: Border.all(
                      color: appCtrl.appTheme.contentColor, width: 1.5),
                  borderRadius:
                      BorderRadius.circular(AppScreenUtil().borderRadius(5))),
              child: LatoFontStyle(
                  text: CommonTextFont().logOut, fontSize: FontSizes.f16)));
    });
  }
}

void showLogoutDialog(void Function()? onPressed) {
  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      insetPadding: const EdgeInsets.all(15),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CommonTextFont().logOut,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const VSpace(Sizes.s15),
            const Text(
              "Are you sure you want to logout?",
            ),
            const VSpace(Sizes.s20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    color: Colors.transparent,
                    border: Border.all(
                      color: appCtrl.appTheme.primary,
                    ),
                    onTap: () {
                      Get.back();
                    },
                    title: "Cancel",
                    fontColor: appCtrl.appTheme.primary,
                  ),
                ),
                Expanded(
                  child: CustomButton(
                      title: CommonTextFont().logOut, onTap: onPressed),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
