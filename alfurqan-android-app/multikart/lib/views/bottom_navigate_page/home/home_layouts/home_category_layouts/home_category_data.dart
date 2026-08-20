import '../../../../../config.dart';

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
              right: AppScreenUtil().screenWidth(12),
              left: AppScreenUtil().screenWidth(index == 0 ? 10 : 0)),
          child: Column(
            children: [
              SizedBox(
                height: AppScreenUtil().screenHeight(70),
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      width: AppScreenUtil().screenWidth(55),
                      decoration: BoxDecoration(
                        color: homeCtrl.appCtrl.appTheme.homeCategoryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Positioned(
                      top: MediaQuery.of(context).size.width > 400
                          ? MediaQuery.of(context).size.height / 100
                          : MediaQuery.of(context).size.width < 380
                              ? 5
                              : 0,
                      child: FadeInImageLayout(
                          image: data!.image.toString(),
                          height: AppScreenUtil().screenHeight(60),
                          width: AppScreenUtil().screenWidth(60),
                          fit: BoxFit.fill),
                    ),
                  ],
                ),
              ),
              LatoFontStyle(
                text: data!.title,
                fontWeight: FontWeight.w600,
                fontSize: FontSizes.f12,
              )
            ],
          ),
        ),
      );
    });
  }
}
