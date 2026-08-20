import 'package:multikart/config.dart';
import 'package:multikart/views/authentication_page/otp/otp.dart';

class ForgotPasswordController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController txtEmail = TextEditingController();

  //sentOtp
  sendOtp() async {
    Get.generalDialog(
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            height: AppScreenUtil().screenHeight(250),
            margin: EdgeInsets.symmetric(
                horizontal: AppScreenUtil().screenWidth(12)),
            child: OtpScreen(),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position: Tween(begin: const Offset(0, -1), end: const Offset(0, 0))
              .animate(anim1),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
