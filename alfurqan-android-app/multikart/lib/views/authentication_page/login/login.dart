import 'package:multikart/config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final loginCtrl = Get.put(LoginController());

  final GlobalKey<FormState> loginformKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginController>(builder: (_) {
      return PopScope(
        canPop: false,
        onPopInvoked: (canPop) async {
          return Future(() => loginCtrl.isBack ? true : false);
        },
        child: Directionality(
          textDirection:
              loginCtrl.appCtrl.isRTL || loginCtrl.appCtrl.languageVal == "ar"
                  ? TextDirection.rtl
                  : TextDirection.ltr,
          child: AppComponent(
            child: Scaffold(
              body: Form(
                  key: loginformKey,
                  child: SingleChildScrollView(
                      child: LoginBody(
                    formKey: loginformKey,
                  ))),
            ),
          ),
        ),
      );
    });
  }
}
