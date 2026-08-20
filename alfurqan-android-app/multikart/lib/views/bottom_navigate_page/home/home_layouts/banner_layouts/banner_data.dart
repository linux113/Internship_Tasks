import '../../../../../config.dart';

class HomeBannerData extends StatelessWidget {
  final HomeBannerModel? data;

  const HomeBannerData({Key? key, this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return InkWell(
        onTap: (){
          if (data?.slug != null && data!.slug!.isNotEmpty) {
            appCtrl.isSearch = false;
            appCtrl.isNotification = true;
            appCtrl.selectedIndex = 1;
            appCtrl.update();
            Get.forceAppUpdate();
            Get.toNamed(routeName.shopPage, arguments: data!.slug);
            return;
          }
          appCtrl.isSearch = false;
          appCtrl.isNotification = true;
          appCtrl.selectedIndex = 1;
          appCtrl.update();
          Get.forceAppUpdate();
          Get.toNamed(routeName.shopPage,arguments: "All");
        },
        child: Container(
          margin:
              EdgeInsets.only(right: AppScreenUtil().screenWidth(18)),
          decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppScreenUtil().borderRadius(10))),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              HomeWidget().bannerImage(data!.image, context),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BannerTextLayout(
                    data: data,
                  ),
                  // CustomButton(
                  //   height: 25,
                  //   fontSize: FontSizes.f12,
                  //   fontWeight: FontWeight.w500,
                  //   width: AppScreenUtil().screenWidth(100),
                  //   title: (data!.buttonTitle == null || data!.buttonTitle!.isEmpty)
                  //       ? ''.tr
                  //       : data!.buttonTitle.toString(),
                  //   onTap: (){
                  //     appCtrl.isSearch = false;
                  //     appCtrl.isNotification = false;
                  //     appCtrl.selectedIndex = 1;
                  //     appCtrl.update();
                  //     if (data?.slug != null && data!.slug!.isNotEmpty) {
                  //       Get.toNamed(routeName.shopPage, arguments: data!.slug);
                  //     } else {
                  //       Get.toNamed(routeName.shopPage,arguments: "All");
                  //     }
                  //   },
                  // ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
