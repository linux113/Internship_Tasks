import 'package:multikart/widgets/common_text_widget/common_account_text.dart';

import '../../../../config.dart';

class SignUpText extends StatelessWidget {
  const SignUpText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return CommonAccountText(
            text1: CommonTextFont().ifYouAreNew,
            text2: CommonTextFont().createNow,
            textColor: appCtrl.appTheme.blackColor,
            fontWeight: FontWeight.normal,
            onTap: () => Get.toNamed(routeName.signUp));
      }
    );
  }
}
