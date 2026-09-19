import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import '../../config.dart';

/// User avatar — pehle static demo ladki ki PHOTO (template asset) dikhata
/// tha har logged-out state me bhi (confusing). Ab neutral person icon.
///
/// 15/09 (point 6): ProfileController me device-local picked photo saved
/// hoti hai (backend photo save support nahi karta — controller comment
/// dekho). Photo ho to wahi dikhe (profile setting / profile tab / drawer
/// — teeno isi widget se bante hai), warna pehle jaisa neutral icon.
/// ProfileController registered nahi (splash/login jaise screens) to bhi
/// safely icon hi dikhta hai.
class UserIcon extends StatelessWidget {
  final double height;

  const UserIcon({Key? key, this.height = 55}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      Widget neutralIcon() {
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
      }

      if (!Get.isRegistered<ProfileController>()) return neutralIcon();
      return GetBuilder<ProfileController>(builder: (profileCtrl) {
        final path = profileCtrl.profileImagePath;
        if (path.isNotEmpty) {
          // 17/09: same-path FileImage ka purana cached decode na aaye —
          // file ki modified-time ko widget KEY banaya (nayi photo = naya
          // key = fresh decode). Controller pick ke waqt cache evict bhi
          // karta hai; ye double-safety hai.
          final f = File(path);
          ObjectKey? verKey;
          try {
            verKey = ObjectKey(
                'pfp_${f.lastModifiedSync().millisecondsSinceEpoch}');
          } catch (_) {}
          return ClipOval(
            child: Image.file(
              f,
              key: verKey,
              height: AppScreenUtil().size(height),
              width: AppScreenUtil().size(height),
              fit: BoxFit.cover,
              // file delete/locked ho jaye to icon par graceful fallback
              errorBuilder: (_, __, ___) => neutralIcon(),
            ),
          );
        }
        final url = profileCtrl.serverImageUrl;
        if (url.isNotEmpty) {
          return ClipOval(
            child: CachedNetworkImage(
              imageUrl: url,
              height: AppScreenUtil().size(height),
              width: AppScreenUtil().size(height),
              fit: BoxFit.cover,
              placeholder: (_, __) => neutralIcon(),
              errorWidget: (_, __, ___) => neutralIcon(),
            ),
          );
        }
        return neutralIcon();
      });
    });
  }
}
