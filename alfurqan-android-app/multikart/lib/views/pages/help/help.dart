import '../../../config.dart';

class Help extends StatelessWidget {
  final helpCtrl = Get.put(HelpController());

  Help({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HelpController>(builder: (_) {
      return Directionality(
        textDirection: helpCtrl.appCtrl.isRTL ||
            helpCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: helpCtrl.appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(
              text: HelpFont().helpCenter,
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //image layout
                HelpWidget().imageLayout(imageAssets.help),
                const Space(0, 20),
                //help text layout
                HelpWidget().helpText(HelpFont().helpCenter),
                const Space(0, 10),
                HelpWidget().helpDec(HelpFont().helpDesc),
                const Space(0, 20),
                //help list layout
                ...helpCtrl.helpList.asMap().entries.map((e) {
                  return HelpList(data: e.value, index: e.key);
                }).toList()
              ],
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          ),
        ),
      );
    });
  }
}
