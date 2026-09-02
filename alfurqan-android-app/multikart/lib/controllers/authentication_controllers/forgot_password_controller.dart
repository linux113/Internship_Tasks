import 'package:multikart/config.dart';

class ForgotPasswordController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController txtEmail = TextEditingController();

  /// FIX (strict no-fake): pehle "Send OTP" ek DEMO OTP popup kholta tha —
  /// na email jata, na OTP verify hota, na password reset hota (template ka
  /// nakli flow). Backend me password-recovery ka koi endpoint hi nahi hai
  /// (swagger verify — sirf ChangePassword hai jo logged-in user ke liye hai).
  /// Isliye ab HONEST dialog: support se reset karwane ka tareeqa.
  sendOtp() async {
    final email = txtEmail.text.trim();
    Get.defaultDialog(
      title: 'Password Reset',
      middleText:
          'App me abhi automatic password reset available nahi hai.\n\n'
          'Apni registered email${email.isNotEmpty ? ' ($email)' : ''} se '
          'support@alfurqan.ae par request bhejein — hamari team aapka '
          'password reset karke jawab de degi.',
      textConfirm: 'OK',
      confirmTextColor: Colors.white,
      buttonColor: appCtrl.appTheme.primary,
      onConfirm: () => Get.back(),
    );
  }
}
