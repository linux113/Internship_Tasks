import '../../config.dart';

/// User avatar — pehle static demo ladki ki PHOTO (template asset) dikhata
/// tha har logged-out state me bhi (confusing). Ab neutral person icon.
class UserIcon extends StatelessWidget {
  final double height;

  const UserIcon({Key? key, this.height = 55}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
        height: AppScreenUtil().size(height),
        width: AppScreenUtil().size(height),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: appCtrl.appTheme.primary.withOpacity(.10),
        ),
        child: Icon(
          Icons.person_outline,
          size: AppScreenUtil().size(height * .65),
          color: appCtrl.appTheme.primary,
        ),
      );
    });
  }
}
