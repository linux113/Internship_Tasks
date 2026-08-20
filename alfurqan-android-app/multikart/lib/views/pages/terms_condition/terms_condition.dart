

import '../../../config.dart';

class TermsAndCondition extends StatelessWidget {
  final termsConditionCtrl = Get.put(TermsAndConditionController());

  TermsAndCondition({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TermsAndConditionController>(builder: (_) {
      return  Directionality(
        textDirection: termsConditionCtrl.appCtrl.isRTL ||
            termsConditionCtrl.appCtrl.languageVal == "ar"
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            elevation: 0,
            automaticallyImplyLeading: false,
            leading: const BackArrowButton(),
            backgroundColor: termsConditionCtrl.appCtrl.appTheme.whiteColor,
            title: LatoFontStyle(
              text: CommonTextFont().termsCondition,
              fontSize: FontSizes.f15,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottomNavigationBar:
          GetBuilder<DashboardController>(builder: (dashboardCtrl) {
            return CommonBottomNavigation(
              onTap: (val) => dashboardCtrl.bottomNavigationChange(val, context),
            );
          }),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //terms & condition text layout
                TermsConditionWidget().commonText(
                    CommonTextFont().termsConditionForMultikart, FontWeight.w700),
                const Space(0, 20),

                //terms & condition list
                ...termsConditionCtrl.termsAndConditionList
                    .asMap()
                    .entries
                    .map((e) {
                  return TermsConditionCard(
                    termsAndConditionModel: e.value,
                  );
                }).toList()
              ],
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          ),
        ),
      );
    });
  }
}
