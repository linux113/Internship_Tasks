import '../../config.dart';

class SettingController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());


  // FIX: Notification toggle HATA DIYA — wo decorative tha
  // (isNotificationShow kahin read/persist hi nahi hota tha, aur app me
  // push notifications wired nahi hai). Sirf REAL working toggles yaha:
  // Mode (theme, persist hota hai) aur RTL (ab persist hota hai).
  var settingData = <ProfileModel>[
    ProfileModel(icon: svgAssets.setting,title: 'Mode'.tr,subTitle: ''),
    ProfileModel(icon: svgAssets.setting,title: 'RTL'.tr,subTitle: ''),
  ];

}
