import 'package:multikart/config.dart';
import 'package:multikart/models/login_response_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';
import 'package:multikart/controllers/home_product_controllers/wishlist_controller.dart';

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

      // Profile tab pehle se khuli ho to usme turant naya naam/email + logout
      // button dikhe (guest -> logged-in UI turant refresh ho jaye).
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().loadUserData();
      }

      // login ke baad SERVER wishlist sync ho jaye (background) — is user ki
      // wishlist server se aake local me mil jayegi.
      // ignore: unawaited_futures
      WishlistController.ensureServerSync();

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
    isBack = Get.arguments ?? false;
    // FIX (user report): already logged-in user ko app kholte hi dobara
    // LOGIN screen dikh jaata tha (kisi navigation/state-mismatch ki wajah
    // se). Ab agar session active hai to login screen kabhi render hi nahi
    // hogi — seedha dashboard par wapas. Logout ke baad flag false hota
    // hai, isliye waha koi farak nahi padega.
    final loggedIn = (storage.read(Session.isLogin) ?? false) == true;
    if (loggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(routeName.dashboard);
      });
      return;
    }
    update();
    super.onReady();
  }
}
