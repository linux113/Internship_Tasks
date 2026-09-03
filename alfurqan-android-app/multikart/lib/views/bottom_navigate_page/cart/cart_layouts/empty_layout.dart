import '../../../../config.dart';

class EmptyLayout extends StatelessWidget {
final String? title,desc;
  const EmptyLayout({Key? key,this.title,this.desc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imageAssets.noData)
                .marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
           const Space(0, 30),
            LatoFontStyle(
              text: title,
              fontSize: FontSizes.f18,
              fontWeight: FontWeight.w700,
              color: appCtrl.appTheme.blackColor,
            ),
             const Space(0, 15),
            LatoFontStyle(
              text:
                  desc,
              fontSize: FontSizes.f16,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.normal,
              overflow: TextOverflow.clip,
              color: appCtrl.appTheme.contentColor,
            ),
            const Space(0, 30),
            // FIX (Issue #8): "Start Shopping" button ka koi onTap hi nahi
            // tha (dead button). Ab home tab par le jata hai.
            CustomButton(
              title: CommonTextFont().startShopping.toUpperCase(),
              fontSize: FontSizes.f16,
              fontWeight: FontWeight.w600,
              onTap: () {
                appCtrl.selectedIndex = 0;
                appCtrl.isHeart = true;
                appCtrl.isCart = true;
                appCtrl.isSearch = true;
                appCtrl.isNotification = true;
                Get.until((route) =>
                    route.settings.name == routeName.dashboard ||
                    route.isFirst);
                appCtrl.update();
                Get.forceAppUpdate();
              },
            )
          ],
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
      );
    });
  }
}
