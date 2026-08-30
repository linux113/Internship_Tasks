import '../../../config.dart';

/// TERMS & CONDITIONS — pehle STATIC demo text. Ab backend ke CMS Pages
/// (`api/Pages/GetAllPages`) se REAL content (slug/title me "term" dhundh
/// kar). Backend me page nahi mila to "content available nahi" dikhega —
/// demo text wapas NAHI aayega.
class TermsAndCondition extends StatelessWidget {
  final termsConditionCtrl = Get.put(TermsAndConditionController());
  // BUG-FIX: Terms/About PEHLE ek hi CmsPageController share karte the —
  // About kholne se Terms page ka content bhi badal jata tha. Ab har page
  // ka ALAG tagged instance hai ('cms-term' vs 'cms-about').
  final cmsCtrl = Get.isRegistered<CmsPageController>(tag: 'cms-term')
      ? Get.find<CmsPageController>(tag: 'cms-term')
      : Get.put(CmsPageController(), tag: 'cms-term');

  TermsAndCondition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    cmsCtrl.loadFor('term');
    return GetBuilder<CmsPageController>(
        tag: 'cms-term',
        builder: (_) {
      final appCtrl = termsConditionCtrl.appCtrl;
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
              text: CommonTextFont().termsCondition,
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
                                : "Terms & Conditions ka content abhi backend me add nahi hua",
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
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15),
                vertical: Insets.i20),
          ),
        ),
      );
    });
  }
}
