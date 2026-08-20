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
                      text: profileCtrl.userName.isNotEmpty
                          ? profileCtrl.userName
                          : CommonTextFont().profileName,
                      fontSize: FontSizes.f16,
                      fontWeight: FontWeight.w700,
                      color: profileCtrl.appCtrl.appTheme.blackColor),
                  LatoFontStyle(
                      text: profileCtrl.userEmail.isNotEmpty
                          ? profileCtrl.userEmail
                          : CommonTextFont().email,
                      fontSize: FontSizes.f12,
                      fontWeight: FontWeight.normal,
                      color: profileCtrl.appCtrl.appTheme.contentColor),
                  const Space(0, 10),
                /*  CustomButton(
                      title: CommonTextFont().edit,
                      width: AppScreenUtil().screenWidth(100),
                      fontWeight: FontWeight.w600,
                      fontSize: FontSizes.f14,
                      height: AppScreenUtil().screenHeight(25),
                      margin: 0)*/
                  Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppScreenUtil().screenWidth(5),
                          vertical: AppScreenUtil().screenHeight(2)),
                      decoration: BoxDecoration(
                          color: profileCtrl.appCtrl.appTheme.primary,
                          borderRadius: BorderRadius.circular(
                              AppScreenUtil().borderRadius(2))),
                      child: LatoFontStyle(
                          text: CommonTextFont().edit,
                          fontSize: FontSizes.f10,
                          fontWeight: FontWeight.w600,
                          color: profileCtrl.appCtrl.appTheme.white))
                ]),
          ]));
    });
  }
}
