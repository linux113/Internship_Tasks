import 'package:multikart/config.dart';
import 'package:multikart/controllers/spalsh_controller.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final splashCtrl = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashController>(
      builder: (_) {
        return Scaffold(
          body: Center(
            child:Center(
              child: AnimatedContainer(
                height: splashCtrl.isTapped ? AppScreenUtil().screenHeight(220.0) : AppScreenUtil().screenHeight(100.0),
                width: splashCtrl.isTapped ? AppScreenUtil().screenHeight(220.0) : AppScreenUtil().screenHeight(100.0),
                duration: const Duration(seconds: 2),
                curve: Curves.fastOutSlowIn,
                child: Hero(tag: 'cat',child: Image.asset(imageAssets.logo)),
              ),
            ),
          ),
        );
      }
    );
  }
}
