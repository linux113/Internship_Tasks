import '../../../../config.dart';

class StatisticCard extends StatelessWidget {
  final Statistic? statistic;

  const StatisticCard({Key? key, this.statistic}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      return Container(
        padding: EdgeInsets.only(
            left: AppScreenUtil().screenWidth(15),
            right: AppScreenUtil().screenWidth(10)),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: appCtrl.appTheme.greyLight25,
            borderRadius:
                BorderRadius.circular(AppScreenUtil().borderRadius(5))),
        child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
              Row(children: [
                SvgPicture.asset(statistic!.image!,
                    height: AppScreenUtil().screenHeight(20)),
                const Space(10, 0),
                LatoFontStyle(
                    text: statistic!.count.toString(),
                    fontSize: FontSizes.f13,
                    color: appCtrl.appTheme.blackColor,
                    fontWeight: FontWeight.w600),
                const Space(5, 0),
                LatoFontStyle(
                    text: statistic!.title.toString().tr,
                    fontSize: FontSizes.f10,
                    overflow: TextOverflow.clip,
                    color: appCtrl.appTheme.blackColor,
                    fontWeight: FontWeight.w600)
              ]),
              const Space(0, 10),
              LatoFontStyle(
                  text: statistic!.desc.toString().tr,
                  fontSize: FontSizes.f10,
                  overflow: TextOverflow.clip,
                  color: appCtrl.appTheme.contentColor,
                  fontWeight: FontWeight.w600)
            ])),
      );
    });
  }
}
