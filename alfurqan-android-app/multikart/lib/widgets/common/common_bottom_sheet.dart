import '../../config.dart';

class CommonBottomSheet extends StatelessWidget {
  final String? text;

  const CommonBottomSheet({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              LatoFontStyle(
                  text: "$text :",
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w700,
                  color: appCtrl.appTheme.blackColor),
              const Space(0, 10),
              LatoFontStyle(
                  text: text == CommonTextFont().moveToWishList
                      ? CommonTextFont().moveToWishListDesc
                      : CommonTextFont().removeDesc,
                  fontSize: FontSizes.f14,
                  fontWeight: FontWeight.w600,
                  color: appCtrl.appTheme.contentColor,
                  overflow: TextOverflow.clip)
            ],
          ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15)),
          Container(
              width: MediaQuery.of(Get.context!).size.width,
              padding: EdgeInsets.symmetric(
                  vertical: AppScreenUtil().screenHeight(12),
                  horizontal: AppScreenUtil().screenWidth(15)),
              decoration: BoxDecoration(
                color: appCtrl.appTheme.whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: appCtrl.appTheme.lightGray,
                    spreadRadius: 10,
                    blurRadius: 5,
                    offset: const Offset(0, 7), // changes position of shadow
                  )
                ],
              ),
              child: IntrinsicHeight(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      LatoFontStyle(
                          text: CommonTextFont().moveToWishList.toUpperCase(),
                          fontWeight: FontWeight.w600,
                          fontSize: FontSizes.f14,
                        onTap: () {
                          Get.back();
                        },),
                      VerticalDivider(
                        color: appCtrl.appTheme.greyLight25,
                      ),
                      LatoFontStyle(
                        text: CommonTextFont().remove.toUpperCase(),
                        fontWeight: FontWeight.w600,
                        color: appCtrl.appTheme.primary,
                        fontSize: FontSizes.f14,
                        onTap: () {
                          Get.back();
                        },
                      )
                    ]),
              ))
        ],
      ).height(AppScreenUtil().screenHeight(150));
    });
  }
}
