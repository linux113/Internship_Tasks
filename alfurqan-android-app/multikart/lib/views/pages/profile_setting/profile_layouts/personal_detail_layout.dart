import 'package:multikart/config.dart';

class PersonalDetailLayout extends StatelessWidget {
  const PersonalDetailLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileCtrl) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileWidget().commonTitleTextLayout(ProfileFont().personalDetail),
          const Space(0, 20),
          ProfileWidget().commonTextBox(ProfileFont().firstName,
              controller: profileCtrl.txtFirstName,
              focusNode: profileCtrl.firstNameFocus, onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
                context, profileCtrl.firstNameFocus, profileCtrl.lastNameFocus);
          }),
          const Space(0, 30),
          ProfileWidget().commonTextBox(ProfileFont().lastName,
              controller: profileCtrl.txtLastName,
              focusNode: profileCtrl.lastNameFocus, onFieldSubmitted: (value) {
            AddAddressWidget().fieldFocusChange(
                context, profileCtrl.lastNameFocus, profileCtrl.dobFocus);
          }),
          const Space(0, 30),
          // FIX (user report — strict): DOB plain TEXT INPUT tha — user
          // kuch bhi type kar sakta tha ("abc", "32/13/9999"). Ab readOnly
          // field + tap par REAL DATE PICKER khulta hai (calendar icon ke
          // saath). Format backend-friendly yyyy-MM-dd.
          CustomTextFormField(
              radius: 5,
              labelText: ProfileFont().dob,
              controller: profileCtrl.txtDob,
              focusNode: profileCtrl.dobFocus,
              readOnly: true,
              suffixIcon: Icon(Icons.date_range_outlined,
                  color: profileCtrl.appCtrl.appTheme.contentColor),
              keyboardType: TextInputType.none,
              onTap: () => profileCtrl.pickDob(context)),
          const Space(0, 30),
          const GenderLayout()
        ],
      ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
    });
  }
}
