import 'package:multikart/views/pages/currency.dart';

import '../../config.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

class ProfileController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();
  CartModel? cartModelList;
  List<ProfileModel> drawerList = [];
  String genderSelectedValue = "Male";

  // ---------------- Logged-in user (Login/Register ke baad save hua data) ----------------
  String userName = "";
  String userEmail = "";

  /// User abhi logged-in hai ya guest mode me hai (splash ab bina-login bhi
  /// dashboard kholta hai — login sirf zaroorat par).
  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  var gender = ["Male", "Female", "Other"];

  TextEditingController txtFirstName = TextEditingController();
  TextEditingController txtLastName = TextEditingController();
  TextEditingController txtDob = TextEditingController();
  TextEditingController txtPhone = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode mobileNumberFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void onReady() {
    // TODO: implement onReady
    drawerList = profileList;
    loadUserData();
    update();
    super.onReady();
  }

  /// login_controller.dart me jo 'name'/'email' storage me save hue the,
  /// wahi yaha se read karke profile page pr dikha rahe hai.
  loadUserData() {
    userName = storage.read('name')?.toString() ?? "";
    userEmail = storage.read('email')?.toString() ?? "";
    // Profile Setting form bhi prefill kar do (name ko first/last me todo)
    if (userName.isNotEmpty && txtFirstName.text.isEmpty) {
      final parts = userName.trim().split(RegExp(r'\s+'));
      txtFirstName.text = parts.first;
      if (parts.length > 1) {
        txtLastName.text = parts.sublist(1).join(' ');
      }
    }
    update();
  }

  bool isSavingProfile = false;

  /// Profile Setting SAVE — PUT api/Core/UpdateUserProfile (user ka curl).
  /// Body: {name, email, phone, country_code, _method:"PUT"}
  Future<void> saveProfile() async {
    if (!isLoggedIn) {
      Get.toNamed(routeName.login);
      return;
    }
    if (isSavingProfile) return;

    final first = txtFirstName.text.trim();
    final last = txtLastName.text.trim();
    final fullName = ('$first $last').trim();
    if (fullName.isEmpty) {
      _toast('Please enter your name');
      return;
    }
    final phoneDigits = txtPhone.text.trim().replaceAll(RegExp('[^0-9]'), '');

    isSavingProfile = true;
    update();
    try {
      final res = await ApiService().request(
        endpoint: ApiEndpoints.updateUserProfile,
        method: ApiMethod.put,
        data: {
          'name': fullName,
          'email': userEmail.isNotEmpty ? userEmail : (storage.read('email')?.toString() ?? ''),
          'phone': int.tryParse(phoneDigits) ?? 0,
          'country_code': 0,
          '_method': 'PUT',
        },
        fromJson: (json) => json,
      );
      isSavingProfile = false;
      update();
      if (res.isSuccess) {
        // naya naam har jagah (storage/profile page/drawer) update ho jaye
        await storage.write('name', fullName);
        userName = fullName;
        update();
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Profile updated successfully');
        Get.back();
      } else {
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Could not update profile. Please try again.');
      }
    } catch (_) {
      isSavingProfile = false;
      update();
      _toast('Could not update profile. Please try again.');
    }
  }

  void _toast(String msg) {
    final socialLoginCtrl = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    socialLoginCtrl.showToast(msg);
  }

  //language bottom sheet
  bottomSheet(isLanguage) {
    Get.bottomSheet(
      BottomSheetLayout(child: isLanguage? LanguageBottomSheet(): CurrencyBottomSheet()),
      backgroundColor: appCtrl.appTheme.whiteColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(AppScreenUtil().borderRadius(15)),
            topLeft: Radius.circular(AppScreenUtil().borderRadius(15))),
      ),
    );
  }

//go to page index wise
  goToPage(index) async {
    appCtrl.isShimmer =true;
    appCtrl.update();
    if (index == 2) {
      Get.toNamed(routeName.pageList);
    } else if (index == 3) {
      Get.toNamed(routeName.orderHistory);
    } else if (index == 4) {
      DashboardController dashboardController = Get.find();
      appCtrl.isCart = true;
      dashboardController.bottomNavigationChange(3, Get.context);

      await storage.write(Session.selectedIndex, index);
      appCtrl.update();
    } else if (index == 5) {
      Get.toNamed(routeName.cardBalance);
    } else if (index == 6) {
      Get.toNamed(routeName.saveAddress);
    } else if (index == 7) {
      bottomSheet(true);
    }  else if (index == 8) {
      bottomSheet(false);
    } else if (index == 9) {
      Get.toNamed(routeName.notification);
    } else if (index == 10) {
      Get.toNamed(routeName.setting);
    } else if (index == 11) {
      Get.toNamed(routeName.profileSetting);
    }else if (index == 12) {
      Get.toNamed(routeName.termsCondition);
    }else if (index == 13) {
      Get.toNamed(routeName.help);
    }
    update();
    await Future.delayed(DurationsClass.s1);
    appCtrl.isShimmer =false;
    appCtrl.update();
    Get.forceAppUpdate();
  }
}
