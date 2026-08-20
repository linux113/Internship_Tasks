import 'package:multikart/config.dart';
import 'package:multikart/models/user_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

class SignUpController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final socialLoginCtrl = Get.isRegistered<SocialLoginController>()
      ? Get.find<SocialLoginController>()
      : Get.put(SocialLoginController());

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtName = TextEditingController();

  // NOTE: AddUser api ko phone + country_code bhi chahiye.
  // Abhi UI me alag se phone field nahi hai (email/phone ek hi field me hai),
  // isliye yaha default controllers add kar diye - jab UI me phone field
  // add karoge to bas isi controller se bind kar dena.
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtCountryCode = TextEditingController(text: '91');

  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  bool passwordVisible = true;

  // Toggle Between Password show
  toggle() {
    passwordVisible = !passwordVisible;
    update();
  }

  /// Real api register (Core/AddUser)
  signInClick({context}) async {
    if (signupFormKey.currentState != null &&
        !signupFormKey.currentState!.validate()) {
      return;
    }

    socialLoginCtrl.showLoading();
    update();

    FocusScopeNode currentFocus = FocusScope.of(Get.context!);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    final res = await ApiService().request<UserModel>(
      endpoint: ApiEndpoints.register,
      method: ApiMethod.post,
      data: {
        "name": txtName.text.trim(),
        "email": txtEmail.text.trim(),
        "phone": txtPhone.text.trim(),
        "country_code": txtCountryCode.text.trim(),
        "password": txtPassword.text.trim(),
        "password_confirmation": txtPassword.text.trim(),
        "role_name": "consumer",
      },
      fromJson: (json) => UserModel.fromJson(json),
    );

    socialLoginCtrl.hideLoading();
    update();

    if (res.isSuccess) {
      txtName.text = "";
      txtEmail.text = "";
      txtPassword.text = "";
      txtPhone.text = "";
      FocusScope.of(Get.context!).requestFocus(FocusNode());
      update();

      socialLoginCtrl.showToast(res.message.isNotEmpty ? res.message : 'Registration successful. Please login.');
      Get.back();
    } else {
      socialLoginCtrl.showToast(res.message.isNotEmpty ? res.message : 'Registration failed. Please try again.');
    }
  }
}
