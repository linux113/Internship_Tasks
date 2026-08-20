import '../../config.dart';

class HeartIcon extends StatelessWidget {
  final Color? color;
  const HeartIcon({Key? key,this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return SvgPicture.asset(
          svgAssets.heart,
          fit: BoxFit.contain,
          height: AppScreenUtil().size(20),
          colorFilter: ColorFilter.mode(
              color ?? appCtrl.appTheme.contentColor, BlendMode.srcIn),
        );
      }
    );
  }
}
