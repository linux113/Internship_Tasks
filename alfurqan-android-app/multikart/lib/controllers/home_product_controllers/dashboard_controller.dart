import 'package:multikart/controllers/home_product_controllers/drawer_controller.dart';

import 'package:flutter/services.dart';

import '../../config.dart';

class DashboardController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  AnimationController? drawerSlideController;

  final drawerCtrl = Get.isRegistered<DrawerPageController>()
      ? Get.find<DrawerPageController>()
      : Get.put(DrawerPageController());

  List drawerList = [];
  final storage = LocalStorage();

  // ---------------- Phone BACK gesture (issue #12 ka dashboard hissa) ----------------
  // Dashboard app ka ROOT screen hai. Pehle yaha PopScope(canPop:false) tha
  // bina kisi handler ke — isliye home screen par back gesture BILKUL dead tha.
  // Ab standard shopping-app behaviour:
  //   1) kisi aur tab par ho (category/wishlist/cart/profile) → pehle home tab par lao
  //   2) home tab par ho → 2 second ke andar back DOBARA dabao tabhi app band hogi
  //      (single accidental back se app band nahi hogi — toast dikhega)
  DateTime? lastBackPress;

  void backPressAction(context) {
    if (appCtrl.selectedIndex != 0) {
      bottomNavigationChange(0, context);
      return;
    }
    final now = DateTime.now();
    if (lastBackPress == null ||
        now.difference(lastBackPress!) > const Duration(seconds: 2)) {
      lastBackPress = now;
      snackBar('Press back again to exit', duration: 'short');
      return;
    }
    SystemNavigator.pop();
  }

  @override
  void onReady() async {
    appCtrl.isShimmer = true;
    appCtrl.update();
    drawerList = AppArray().drawerList;
    update();
    appCtrl.isShimmer = false;
    appCtrl.update();
    Get.forceAppUpdate();
    super.onReady();
  }

  //bottom change
  bottomNavigationChange(val, context) async {

    appCtrl.selectedIndex = val;
    appCtrl.isLoading = true;
    appCtrl.isShimmer = true;
    appCtrl.update();

    await storage.write(Session.selectedIndex, val);

    appCtrl.rightValue = MediaQuery.of(context).size.width;
    if (appCtrl.selectedIndex == 0) {
      appCtrl.isHeart = true;
      appCtrl.isCart = true;
      appCtrl.isShare = false;
      appCtrl.isSearch = true;
      appCtrl.isNotification = true;
    } else if (appCtrl.selectedIndex == 1) {
      appCtrl.isHeart = true;
      appCtrl.isCart = true;
      appCtrl.isShare = false;
      appCtrl.isSearch = false;
      appCtrl.isNotification = false;
    } else if (appCtrl.selectedIndex == 2) {
      appCtrl.isHeart = true;
      appCtrl.isCart = false;
      appCtrl.isShare = false;
      appCtrl.isSearch = false;
      appCtrl.isNotification = false;
    } else if (appCtrl.selectedIndex == 3) {
      appCtrl.isHeart = false;
      appCtrl.isCart = true;
      appCtrl.isShare = false;
      appCtrl.isSearch = false;
      appCtrl.isNotification = false;
    } else if (appCtrl.selectedIndex == 4) {
      appCtrl.isHeart = false;
      appCtrl.isCart = false;
      appCtrl.isShare = false;
      appCtrl.isSearch = false;
      appCtrl.isNotification = false;
    }
    appCtrl.isLoading = false;


    update();
    if(appCtrl.selectedIndex != 4) {
      await Future.delayed(DurationsClass.s1);
    }
    appCtrl.isShimmer = false;
    appCtrl.update();
    update();
    Get.forceAppUpdate();
  }

  //app bar leading action
  appBarLeadingAction() async {
    appCtrl.goToHome();
    await storage.write(Session.selectedIndex, 0);
    appCtrl.selectedIndex = 0;
    update();
  }


}
