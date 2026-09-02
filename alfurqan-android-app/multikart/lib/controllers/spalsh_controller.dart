
import 'dart:developer';

import 'package:multikart/config.dart';
import 'package:multikart/services/api_service.dart';

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
    // SELF-HEAL: auth token saved hai par login flag kisi wajah se false
    // reh gaya ho to yahi theek kar do — user se bewajah dobara login nahi
    // manga jayega (user report: app kholte hi login screen aati thi jabki
    // profile me wo already logged-in tha).
    final storedToken = ApiService().token;
    if ((storedToken ?? '').isNotEmpty && isLogin != true) {
      await storage.write(Session.isLogin, true);
    }
    // FIX: pehle Get.toNamed use hota tha — Splash stack ME HI pada rehta
    // tha, aur login page par back dabane par splash dobara chal kar
    // checkLogin -> login par wapas phenk deta tha (user ko lagta tha
    // "app logout ho gayi / back kaam nahi kar raha"). Ab offAll se
    // navigation stack bilkul clean hota hai.
    if (isIntro.toString() == "false") {
      Get.offAllNamed(routeName.onBoarding);
    } else {
      // FIX: pehle bina-login user ko hamesha LOGIN screen par fenk diya
      // jata tha — isliye app kholte hi / back dabate hi baar-baar login
      // milta tha. Ab GUEST MODE: bina login bhi seedha dashboard (home)
      // khulega. Login sirf tab maanga jayega jab koi protected kaam ho
      // (Add to Cart / Checkout / Profile) — ek baar login karne ke baad
      // app band karke kholo tab bhi session yaad rehta hai.
      Get.offAllNamed(routeName.dashboard);
    }
  }
}
