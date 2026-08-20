import '../../../../config.dart';

class AboutUsBody extends StatelessWidget {
  const AboutUsBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AboutUsController>(
      builder: (aboutUsCtrl) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //introduction text layout
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AboutUsWidget().commonText(AboutUSFont().introduction,
                    FontWeight.w700, FontSizes.f16),
                const Space(0, 20),

                //about us image layout
                AboutUsWidget().imageLayout(imageAssets.aboutUs),
                const Space(0, 20),
                //title text layout
                AboutUsWidget().commonText(aboutUsCtrl.aboutUsModel!.title.toString().tr,
                    FontWeight.w600, FontSizes.f14),
                const Space(0, 20),

                //description1 text layout
                AboutUsWidget()
                    .commonDescText(aboutUsCtrl.aboutUsModel!.desc1.toString().tr),
                const Space(0, 20),

                //description2 text layout
                AboutUsWidget()
                    .commonDescText(aboutUsCtrl.aboutUsModel!.desc2.toString().tr),
                const Space(0, 30),

                //statistic layout
                const AboutUsStatistic(),
                const Space(0, 30),
                //description3 text layout
                AboutUsWidget()
                    .commonDescText(aboutUsCtrl.aboutUsModel!.desc3.toString().tr),
                const Space(0, 20),
                AboutUsWidget().commonText(AboutUSFont().ourBrandTitle,
                    FontWeight.w700, FontSizes.f16),
                const Space(0, 20),

                //our brand text layout
                AboutUsWidget()
                    .commonDescText(aboutUsCtrl.aboutUsModel!.ourBrand.toString().tr),
                const Space(0, 20),
              ],
            ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),

            //our brand layout
            const CommonBrandLayout()
          ],
        );
      }
    );
  }
}
