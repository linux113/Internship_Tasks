import '../../config.dart';

class LogoImage extends StatelessWidget {
  const LogoImage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: pehle sirf width di gayi thi — logo image tall hone ki wajah se
    // app bar me bahut BADA dikhta tha. Ab height fix (app bar ke hisaab se
    // chhota size) hai aur width apne aap sahi proportion me aa jayegi.
    return Image.asset(
      imageAssets.logo,
      fit: BoxFit.contain,
      height: AppScreenUtil().screenHeight(38),
    );
  }
}
