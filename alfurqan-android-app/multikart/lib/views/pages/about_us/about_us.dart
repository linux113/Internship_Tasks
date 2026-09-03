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
                  // Issue#11: backend CMS khali ho to bhi ASLI shop info
                  // dikhao (website/about ke real details); backend me
                  // Pages content aate hi wahi overwrite karega.
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    if (cmsCtrl.loadFailed) ...[
                      const Space(0, 20),
                      Center(
                        child: LatoFontStyle(
                                text: "Retry",
                                color: appCtrl.appTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: FontSizes.f14)
                            .gestures(onTap: () => cmsCtrl.retry()),
                      ),
                    ],
                    const Space(0, 20),
                    LatoFontStyle(
                        text:
                            "Al Furqan Book Shop (alfurqan.ae) is an online Islamic bookstore based in the UAE. We bring you a wide collection of authentic Islamic books — Quran, Hadees, Fiqh, Seerah, Aqeedah, children's Islamic stories, Arabic learning and more.",
                        overflow: TextOverflow.clip,
                        fontSize: FontSizes.f13,
                        color: appCtrl.appTheme.contentColor),
                    const Space(0, 15),
                    LatoFontStyle(
                        text:
                            "Our aim is simple: make authentic Islamic knowledge easily available for every home, with fair prices, Cash on Delivery and fast shipping across the UAE.",
                        overflow: TextOverflow.clip,
                        fontSize: FontSizes.f13,
                        color: appCtrl.appTheme.contentColor),
                    const Space(0, 15),
                    LatoFontStyle(
                        text:
                            "Shop easily from the app, save your favourite books to the wishlist, and track your orders anytime. For any help, our support team is one email away: support@alfurqan.ae",
                        overflow: TextOverflow.clip,
                        fontSize: FontSizes.f13,
                        color: appCtrl.appTheme.contentColor),
                    const Space(0, 40),
                  ]).marginSymmetric(
                      horizontal: AppScreenUtil().screenWidth(15)),
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
