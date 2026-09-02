import '../../config.dart';

class SkipTextWidget extends StatelessWidget {
  final GestureTapCallback? onTap;
  final bool? isDone;
  const SkipTextWidget(
      {Key? key,
        this.onTap,this.isDone})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // FIX: 'DONE'/'SKIP' keys map me nahi the — AR/HI/KR mode me raw
    // English dikhta tha. 'done'/'skip' keys 4 languages me maujood hai.
    return  Text(
     (isDone ?? false) ? 'done'.tr : 'skip'.tr,
    )
        .fontFamily(GoogleFonts.lato().fontFamily.toString())
        .fontSize(AppScreenUtil().fontSize(FontSizes.f16))
        .fontFamily(FontWeight.w700.toString()).gestures(onTap: onTap);
  }
}