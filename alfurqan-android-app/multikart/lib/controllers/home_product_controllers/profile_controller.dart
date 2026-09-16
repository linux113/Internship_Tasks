import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:multikart/models/json_parse_utils.dart';
import 'package:multikart/views/pages/currency.dart';
import 'package:path_provider/path_provider.dart';

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
  // Change password ke liye CURRENT password box (backend ko purana + naya
  // dono chahiye — PasswordChangeDto)
  TextEditingController txtCurrentPassword = TextEditingController();
  final FocusNode firstNameFocus = FocusNode();
  final FocusNode lastNameFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode mobileNumberFocus = FocusNode();
  final FocusNode currentPasswordFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void onReady() {
    drawerList = profileList;
    loadUserData();
    update();
    // Server se bhi detail lao (phone etc. jo login response me nahi aata)
    fetchServerProfile();
    super.onReady();
  }

  /// GET api/Core/GetUserDetail — token se user pata chalta hai.
  /// Response (AccountDetailDto): name/email/phone/country_code etc.
  /// Phone abhi local me nahi hai — yahi se prefill hoga.
  Future<void> fetchServerProfile() async {
    if (!isLoggedIn) return;
    try {
      final res = await ApiService().request<Map<String, dynamic>>(
        endpoint: ApiEndpoints.getUserDetail,
        method: ApiMethod.get,
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            final m = Map<String, dynamic>.from(raw as Map);
            if (m.containsKey('email') ||
                m.containsKey('Email') ||
                m.containsKey('name') ||
                m.containsKey('phone')) {
              return m;
            }
            raw = m['data'] ?? m['Data'];
            if (raw == null) return m;
          }
          return raw is Map
              ? Map<String, dynamic>.from(raw as Map)
              : <String, dynamic>{};
        },
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        final m = res.data!;
        final phone = (m['phone'] ?? m['Phone'] ?? '').toString();
        final name =
            (m['name'] ?? m['Name'] ?? m['full_name'] ?? '').toString();
        final email = (m['email'] ?? m['Email'] ?? '').toString();
        if (phone.isNotEmpty && phone != '0') txtPhone.text = phone;
        if (userName.isEmpty && name.isNotEmpty) {
          userName = name;
          final parts = name.trim().split(RegExp(r'\s+'));
          txtFirstName.text = parts.first;
          if (parts.length > 1) {
            txtLastName.text = parts.sublist(1).join(' ');
          }
        }
        if (userEmail.isEmpty && email.isNotEmpty) userEmail = email;
        // Server ka profileImage (Core_Users.profileImage -> MediaFiles)
        // ho to uska URL rakho — local photo nahi tabhi ye dikhta hai.
        final img = m['profile_image'] ??
            m['profileImage'] ??
            m['profile_img'] ??
            m['avatar'];
        if (img is Map) {
          final u = jsonToString(img['asset_url'] ??
              img['original_url'] ??
              img['Asset_Url'] ??
              img['url']);
          if (u != null && u.isNotEmpty) serverImageUrl = u;
        }
        update();
      }
    } catch (_) {}
  }

  bool isChangingPassword = false;

  /// POST api/Core/ChangePassword — body:
  /// {current_password, new_password, confirm_password} (PasswordChangeDto)
  Future<void> changePassword() async {
    if (!isLoggedIn) {
      _toast('Please login first');
      Get.toNamed(routeName.login);
      return;
    }
    if (isChangingPassword) return;
    final current = txtCurrentPassword.text.trim();
    final newPass = txtPassword.text.trim();
    if (current.isEmpty || newPass.isEmpty) {
      _toast('Current aur new password dono likho');
      return;
    }
    if (newPass.length < 6) {
      _toast('New password kam se kam 6 characters ka ho');
      return;
    }
    isChangingPassword = true;
    update();
    try {
      final res = await ApiService().request(
        endpoint: ApiEndpoints.changePassword,
        method: ApiMethod.post,
        data: {
          'current_password': current,
          'new_password': newPass,
          'confirm_password': newPass,
        },
        fromJson: (json) => json,
      );
      if (res.isSuccess) {
        txtCurrentPassword.clear();
        txtPassword.clear();
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Password changed successfully');
      } else {
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Password change nahi hua — current password check karein');
      }
    } catch (_) {
      _toast('Password change nahi hua — dobara try karein');
    }
    isChangingPassword = false;
    update();
  }

  // ------------- PROFILE PHOTO (15/09 point 6 — DEEP root cause) -------------
  /// SERVER TRUTH (live swagger v2 verify): `PUT api/Core/UpdateUserProfile`
  /// ka `UpdateProfileDto` SIRF {name, email, phone, country_code, _method}
  /// accept karta hai (additionalProperties:false) — PROFILE IMAGE ka koi
  /// field hi NAHI. Saath hi backend me user-media UPLOAD endpoint bhi
  /// NAHI hai (`api/Media` sirf GetAllMediaFiles + DeleteAllMedia deta
  /// hai; upload sirf admin `BulkUpload/UploadBulkMedia`). Matlab server
  /// par photo SAVE karna techically possible hi nahi — isliye photo ab
  /// DEVICE me (app documents folder) per-user save hoti hai aur profile
  /// setting / profile tab / drawer — teeno jagah wahi dikhti hai. Jab
  /// backend profile_image_id support karega to upload wiring chhoti hai.
  String profileImagePath = ''; // device-local picked photo ka path
  String serverImageUrl = ''; // server ka profileImage (ho to — rare)

  /// Per-user storage key (doosre account login par purani photo nahi).
  String get _photoKey => 'profile_image_path_${storage.read('id') ?? 0}';

  /// Saved photo ka path load karo (file delete ho chuki ho to reset).
  void loadProfileImage() {
    try {
      final p = storage.read(_photoKey)?.toString() ?? '';
      if (p.isNotEmpty && File(p).existsSync()) {
        profileImagePath = p;
      } else {
        profileImagePath = '';
      }
    } catch (_) {
      profileImagePath = '';
    }
  }

  bool isPickingImage = false;

  /// Gallery se photo chuno -> app documents me copy (+ purani replace)
  /// -> storage save -> teeno jagah (UserIcon har jagah yahi padhta hai)
  /// turant update.
  Future<void> pickProfileImage() async {
    if (!isLoggedIn) {
      Get.toNamed(routeName.login);
      return;
    }
    if (isPickingImage) return;
    isPickingImage = true;
    update();
    try {
      final picked = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxWidth: 512, imageQuality: 85);
      if (picked == null) {
        isPickingImage = false;
        update();
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final target =
          File('${dir.path}/profile_photo_${storage.read('id') ?? 0}.jpg');
      if (await target.exists()) {
        try {
          await target.delete();
        } catch (_) {}
      }
      await File(picked.path).copy(target.path);
      profileImagePath = target.path;
      await storage.write(_photoKey, profileImagePath);
      _toast('profilePhotoUpdated'.tr);
    } catch (_) {
      _toast('photoPickFailed'.tr);
    }
    isPickingImage = false;
    update();
  }

  /// login_controller.dart me jo 'name'/'email' storage me save hue the,
  /// wahi yaha se read karke profile page pr dikha rahe hai.
  loadUserData() {
    loadProfileImage(); // photo bhi har baar fresh (delete/check samet)
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

  /// REAL DATE PICKER — DOB free-text input tha (kuch bhi type ho sakta
  /// tha). Ab calendar se hi select hoga; format yyyy-MM-dd (backend
  /// friendly). Field readOnly hai, typing band.
  Future<void> pickDob(BuildContext context) async {
    DateTime initial = DateTime(2000, 1, 1);
    final parsed = DateTime.tryParse(txtDob.text.trim());
    final today = DateTime.now();
    if (parsed != null &&
        parsed.isAfter(DateTime(1900)) &&
        parsed.isBefore(today)) {
      initial = parsed;
    }
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: today,
      builder: (context, child) {
        // app ke green theme ke saath picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: appCtrl.appTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      txtDob.text =
          "${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      update();
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
