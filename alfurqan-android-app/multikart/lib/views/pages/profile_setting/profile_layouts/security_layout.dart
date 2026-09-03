import 'package:multikart/config.dart';
import 'package:flutter/services.dart';

/// PROFILE SETTING — security section.
/// Pehle: phone box ka label "Date of birth" aata tha (template bug) aur
/// password box kuch save nahi karta tha.
/// Ab: Phone (label sahi), Current Password + New Password boxes jinse
/// REAL api/Core/ChangePassword call hota hai.
class SecurityLayout extends StatelessWidget {
  const SecurityLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileCtrl) {
      final appCtrl = profileCtrl.appCtrl;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileWidget().commonTitleTextLayout(ProfileFont().security),
          const Space(0, 30),

          // ---- Phone (pehle galat label "Date of birth" tha) ----
          ProfileWidget().securityTextBox("Phone",
              keyboardType: TextInputType.phone,
              // FIX (Issue #7): profile phone me bhi symbols type hote
              // the — ab sirf digits (max 15).
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
              focusNode: profileCtrl.mobileNumberFocus,
              controller: profileCtrl.txtPhone,
              onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
              context,
              profileCtrl.mobileNumberFocus,
              profileCtrl.currentPasswordFocus,
            );
          }),
          const Space(0, 30),

          // ---- Current password ----
          ProfileWidget().securityTextBox("Current Password",
              controller: profileCtrl.txtCurrentPassword,
              focusNode: profileCtrl.currentPasswordFocus,
              keyboardType: TextInputType.visiblePassword,
              onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
              context,
              profileCtrl.currentPasswordFocus,
              profileCtrl.passwordFocus,
            );
          }),
          const Space(0, 30),

          // ---- New password ----
          ProfileWidget().securityTextBox("New Password",
              controller: profileCtrl.txtPassword,
              focusNode: profileCtrl.passwordFocus,
              keyboardType: TextInputType.visiblePassword),
          const Space(0, 25),

          // ---- CHANGE PASSWORD button (REAL api call) ----
          GestureDetector(
            onTap: profileCtrl.isChangingPassword
                ? null
                : () => profileCtrl.changePassword(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                  vertical: AppScreenUtil().screenHeight(13)),
              decoration: BoxDecoration(
                color: appCtrl.appTheme.primary,
                borderRadius:
                    BorderRadius.circular(AppScreenUtil().borderRadius(6)),
              ),
              child: Center(
                child: profileCtrl.isChangingPassword
                    ? SizedBox(
                        height: AppScreenUtil().size(18),
                        width: AppScreenUtil().size(18),
                        child: const CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : LatoFontStyle(
                        text: "Change Password",
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: FontSizes.f14),
              ),
            ),
          ),
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
