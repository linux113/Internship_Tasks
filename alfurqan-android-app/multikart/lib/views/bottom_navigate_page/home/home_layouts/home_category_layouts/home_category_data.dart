import '../../../../../config.dart';

/// Home top category row — ICON form: gol (circular) image-icon + niche naam.
/// Image API (Top_Category.TopCategories[].ImageUrl) se aati hai.
class HomeCategoryData extends StatelessWidget {
  final HomeCategoryModel? data;
  final int? index;

  const HomeCategoryData({Key? key, this.data, this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      return InkWell(
        onTap: () async {
          if (data?.slug != null && data!.slug!.isNotEmpty) {
            homeCtrl.goToCategoryProducts(data!.slug);
            return;
          }
          homeCtrl.appCtrl.isHeart = true;
          homeCtrl.appCtrl.isCart = true;
          homeCtrl.appCtrl.isShare = false;
          homeCtrl.appCtrl.isSearch = false;
          homeCtrl.appCtrl.isNotification = false;
          homeCtrl.appCtrl.selectedIndex = 1;
          homeCtrl.appCtrl.update();
          homeCtrl.appCtrl.isShimmer = true;
          homeCtrl.update();
          await Future.delayed(DurationsClass.s1);
          homeCtrl.appCtrl.isShimmer = false;
          homeCtrl.appCtrl.update();
          Get.forceAppUpdate();
        },
        child: Padding(
          padding: EdgeInsets.only(
              right: AppScreenUtil().screenWidth(14),
              left: AppScreenUtil().screenWidth(index == 0 ? 15 : 0)),
          child: Column(
            children: [
              // gol icon — soft brand-green background circle ke andar
              // category photo ka gol circle.
              // 22/09 (Lalit — "category ka CIRCLE square/frame ke BAHAR
              // nikal raha hai"): pehle photo 56px thi 62px frame me
              // (sirf 3px ring) — edge photo ring tak lagti thi isliye
              // "circle frame ke bahar" jaisa dikhta tha. Ab photo circle
              // 52px, frame 70px green circle — beech me saaf 8-9px ka GREEN
              // RING dikhta hai, photo HARD-CLIP ke sath hamesha frame ke
              // ANDAR (kisi bhi device/density par bahar nahi aa sakti).
              Container(
                width: AppScreenUtil().size(70),
                height: AppScreenUtil().size(70),
                padding: EdgeInsets.all(AppScreenUtil().size(6)),
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: homeCtrl.appCtrl.appTheme.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: homeCtrl.appCtrl.appTheme.primary.withOpacity(0.25),
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child: FadeInImageLayout(
                    image: data!.image.toString(),
                    height: AppScreenUtil().size(52),
                    width: AppScreenUtil().size(52),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const Space(0, 6),
              SizedBox(
                // 22/09: label ki width thodi zyada + ek row ki height fix —
                // lambe Arabic naam 3 lines banakar gol photo ko
                // frame se BAHAR dhakel dete the (RenderFlex overflow).
                width: AppScreenUtil().size(80),
                child: LatoFontStyle(
                  text: data!.title,
                  fontWeight: FontWeight.w600,
                  fontSize: FontSizes.f12,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}
