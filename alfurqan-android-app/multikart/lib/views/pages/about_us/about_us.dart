import '../../../config.dart';

/// ABOUT US — pehle STATIC demo text + fake statistics. Ab backend CMS
/// Pages se REAL content (slug/title me "about"). Backend me nahi mila to
/// saaf message dikhega — demo wapas nahi.
class AboutUs extends StatelessWidget {
  final aboutUsCtrl = Get.put(AboutUsController());
  // BUG-FIX: tagged alag instance (Terms se content mix nahi hoga)
  final cmsCtrl = Get.isRegistered<CmsPageController>(tag: 'cms-about')
      ? Get.find<CmsPageController>(tag: 'cms-about')
      : Get.put(CmsPageController(), tag: 'cms-about');

  AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    cmsCtrl.loadFor('about');
    return GetBuilder<CmsPageController>(
        tag: 'cms-about',
        builder: (_) {
      final appCtrl = aboutUsCtrl.appCtrl;
      return Directionality(
        textDirection: appCtrl.isRTL || appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(
              text: AboutUSFont().aboutUs,
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (cmsCtrl.isLoading)
                  Padding(
                    padding:
                        EdgeInsets.only(top: AppScreenUtil().screenHeight(40)),
                    child: Center(
                        child: CircularProgressIndicator(
                            color: appCtrl.appTheme.primary)),
                  )
                else if (cmsCtrl.content.isNotEmpty)
                  LatoFontStyle(
                      text: cmsCtrl.content,
                      overflow: TextOverflow.clip,
                      fontSize: FontSizes.f13,
                      color: appCtrl.appTheme.contentColor)
                else
                  Column(children: [
                    const Space(0, 50),
                    Center(
                        child: LatoFontStyle(
                            text: cmsCtrl.loadFailed
                                ? "Content load nahi hua — Retry par tap karein"
                                : "About Us ka content abhi backend me add nahi hua",
                            textAlign: TextAlign.center,
                            fontSize: FontSizes.f13,
                            color: appCtrl.appTheme.contentColor)),
                    const Space(0, 15),
                    if (cmsCtrl.loadFailed)
                      LatoFontStyle(
                              text: "Retry",
                              color: appCtrl.appTheme.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: FontSizes.f14)
                          .gestures(onTap: () => cmsCtrl.retry()),
                  ]),
                const Space(0, 30),
              ],
            ).marginSymmetric(
                horizontal: AppScreenUtil().screenWidth(15),
                vertical: Insets.i20),
          ),
        ),
      );
    });
  }
}
