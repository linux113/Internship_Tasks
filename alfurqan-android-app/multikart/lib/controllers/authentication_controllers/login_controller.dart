import 'package:multikart/config.dart';
import 'package:multikart/models/login_response_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

class LoginController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final socialLoginCtrl = Get.isRegistered<SocialLoginController>()
      ? Get.find<SocialLoginController>()
      : Get.put(SocialLoginController());

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool isBack = false;
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  bool passwordVisible = true;
  final storage = LocalStorage();

  // Toggle Between Password show
  toggle() {
    passwordVisible = !passwordVisible;
    update();
  }

  /// Real api login (Core/LogInWeb)
  login() async {
    socialLoginCtrl.showLoading();
    update();

    final res = await ApiService().request<LoginResponseModel>(
      endpoint: ApiEndpoints.login,
      method: ApiMethod.post,
      data: {
        "email": txtEmail.text.trim(),
        "password": txtPassword.text.trim(),
      },
      fromJson: (json) => LoginResponseModel.fromJson(json),
    );

    socialLoginCtrl.hideLoading();
    update();

    if (res.isSuccess && res.data != null) {
      final user = res.data!;

      // token + basic user info save karo taaki dubara login na karna pade
      ApiService().saveToken(user.token ?? '');
      await storage.write('id', user.id);
      await storage.write('name', user.name);
      await storage.write('email', user.email);
      await storage.write(Session.isLogin, true);

      txtEmail.text = "";
      txtPassword.text = "";
      update();

      socialLoginCtrl.showToast(res.message.isNotEmpty ? res.message : 'Login successful');
      // FIX: Get.toNamed se login page stack me pada rehta tha — back dabane
      // par user phir se login page par aa jata tha ("logout jaisa" feel).
      // Ab offAll se saara purana stack clear karke dashboard kholte hai.
      Get.offAllNamed(routeName.dashboard);
    } else {
      // e.g. "Invalid email or password" jo bhi backend bhejega
      socialLoginCtrl.showToast(res.message.isNotEmpty ? res.message : 'Login failed. Please try again.');
    }
  }

  @override
  void onReady() {
    // TODO: implement onReady
    isBack = Get.arguments ?? false;

    update();
    super.onReady();
  }
}
