import 'package:multikart/config.dart';
import 'package:multikart/controllers/authentication_controllers/onboarding_controller.dart';
import 'package:multikart/views/authentication_page/onbaording/onboard_constant.dart';
import 'package:multikart/views/authentication_page/onbaording/onboard_list.dart';
import 'package:multikart/widgets/common_text_widget/common_account_text.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen>
    with TickerProviderStateMixin {
  var onBoardingCtrl = Get.put(OnBoardingController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OnBoardingController>(builder: (_) {
      return PopScope(
        canPop: false,
        onPopInvoked: (canPop) async {
          return Future(() => onBoardingCtrl.isBack ? true : false);
        },
        child: Directionality(
          textDirection: onBoardingCtrl.appCtrl.isRTL ||
                  onBoardingCtrl.appCtrl.languageVal == "ar"
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: Scaffold(
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                SizedBox(
                  height: AppScreenUtil().screenHeight(580),
                  child: Stack(children: [
                    //app bar layout
                    AuthenticationAppBar(
                      onTap: () => onBoardingCtrl.readIntroPage(),
                      isDone: onBoardingCtrl.current ==
                              onBoardingCtrl.imgList.length - 1
                          ? true
                          : false,
                    ),

                    //on board list layout
                    const OnBoardList()
                  ]),
                ),
                const Space(0, 5),

                //start shopping button layout
                CustomButton(
                    title: OnBoardFont().startShopping.toUpperCase(),
                    onTap: () => onBoardingCtrl.readIntroPage()),
                const Space(0, 5),

                //already account text layout
                CommonAccountText(
                    text1: CommonTextFont().alreadyAccount,
                    text2: CommonTextFont().signIn,
                    textColor: onBoardingCtrl.appCtrl.appTheme.contentColor,
                    fontWeight: FontWeight.w700,
                    onTap: () => onBoardingCtrl.readIntroPage()),
                const Space(0, 5)
              ])),
        ),
      );
    });
  }
}
