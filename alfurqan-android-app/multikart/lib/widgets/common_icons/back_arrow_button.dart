import 'package:flutter/cupertino.dart';

import '../../config.dart';

class BackArrowButton extends StatelessWidget {
  const BackArrowButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return  Icon(appCtrl.isRTL ||
            appCtrl.languageVal == "ar" ?CupertinoIcons.arrow_right :CupertinoIcons.arrow_left)
            .gestures(onTap: () => smartBack());
      }
    );
  }
}

/// SMART BACK (06/09 user glitch): Order Success → "Track Order"
/// offAllNamed se poora stack saaf ho jata hai — Order History/Detail se
/// back dabate hi user seedha PHONE HOME par gir jata tha (app band!).
/// Stack me page ho to normal back; warna app band hone ke bajaye
/// dashboard (home) khol do.
void smartBack() {
  final nav = Get.key.currentState;
  if (nav != null && nav.canPop()) {
    Get.back();
  } else {
    Get.offAllNamed(routeName.dashboard);
  }
}
