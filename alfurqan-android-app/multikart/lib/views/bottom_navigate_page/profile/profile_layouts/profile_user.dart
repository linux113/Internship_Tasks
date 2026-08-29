import '../../../../config.dart';

class ProfileUser extends StatelessWidget {
  const ProfileUser({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(builder: (profileCtrl) {
      return Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: AppScreenUtil().screenWidth(20)),
          color: profileCtrl.appCtrl.appTheme.greyLight25,
          height: AppScreenUtil().screenHeight(110),
          width: MediaQuery.of(context).size.width,
          child: Row(children: [
            Container(
                height: AppScreenUtil().screenHeight(75),
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: const UserIcon()),
            const Space(20, 0),
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LatoFontStyle(
                      // guest mode me fake name nahi — "Guest" dikhega
                      text: profileCtrl.isLoggedIn
                          ? (profileCtrl.userName.isNotEmpty
                              ? profileCtrl.userName
                              : CommonTextFont().guest)
                          : CommonTextFont().guest,
                      fontSize: FontSizes.f16,
                      fontWeight: FontWeight.w700,
                      color: profileCtrl.appCtrl.appTheme.blackColor),
                  // email sirf logged-in user ka dikhe (fake demo email nahi)
                  if (profileCtrl.isLoggedIn &&
                      profileCtrl.userEmail.isNotEmpty)
                    LatoFontStyle(
                        text: profileCtrl.userEmail,
                        fontSize: FontSizes.f12,
                        fontWeight: FontWeight.normal,
                        color: profileCtrl.appCtrl.appTheme.contentColor),
                  const Space(0, 10),
                  // guest ko SIGN IN chip dikhe (tap -> login page),
                  // logged-in user ko Edit chip.
                  InkWell(
                    onTap: () async {
                      if (!profileCtrl.isLoggedIn) {
                        Get.toNamed(routeName.login);
                      } else {
                        // EDIT chip -> Profile Setting kholo; wapas aane par
                        // updated naam/email dobara dikhe
                        await Get.toNamed(routeName.profileSetting);
                        profileCtrl.loadUserData();
                      }
                    },
                    child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppScreenUtil().screenWidth(
                                profileCtrl.isLoggedIn ? 5 : 12),
                            vertical: AppScreenUtil().screenHeight(
                                profileCtrl.isLoggedIn ? 2 : 5)),
                        decoration: BoxDecoration(
                            color: profileCtrl.appCtrl.appTheme.primary,
                            borderRadius: BorderRadius.circular(
                                AppScreenUtil().borderRadius(2))),
                        child: LatoFontStyle(
                            text: profileCtrl.isLoggedIn
                                ? CommonTextFont().edit
                                : CommonTextFont().signIn,
                            fontSize: FontSizes.f10,
                            fontWeight: FontWeight.w600,
                            color: profileCtrl.appCtrl.appTheme.white)),
                  )
                ]),
          ]));
    });
  }
}
