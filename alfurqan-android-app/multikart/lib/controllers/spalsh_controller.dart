
import 'dart:developer';

import 'package:multikart/config.dart';

class SplashController extends GetxController {
  bool isTapped = false;
final storage = LocalStorage();
  @override
  void onInit() async {
    await Future.delayed(DurationsClass.s3);
    isTapped = true;
    update();
    await Future.delayed(DurationsClass.s1);
    checkLogin();
    super.onInit();
  }

  void checkLogin() async {
    //#region set Language
    String? languageCode = storage.read(Session.languageCode);
    String? countryCode = storage.read(Session.countryCode);
    bool? isLogin = storage.read(Session.isLogin);
    if (languageCode != null && countryCode != null) {
      var locale = Locale(languageCode, countryCode);
      Get.updateLocale(locale);
    } else {
      Get.updateLocale(Get.deviceLocale ?? const Locale('en', 'US'));
    }
    //#endregion

    bool isIntro = storage.read(Session.isIntro) ?? false;
log(isIntro.toString());
    if (isIntro.toString() == "false") {
      Get.toNamed(routeName.onBoarding);
    } else {
      if (isLogin == true) {
        Get.toNamed(routeName.dashboard);
      } else {
        // Checking if user is already login or not
        Get.toNamed(routeName.login);
      }
    }
  }
}
