import '../../../../../config.dart';

/// SERVICES STRIP (Issue #2) — home page par "service container" missing
/// tha. Ab GetHomePageDataApp ke Services section se real data (icon +
/// title + description) horizontal strip me dikhta hai. Backend abhi "Test"
/// placeholder bhejta hai — wo model me filter ho jata hai, isliye strip
/// tabhi dikhti hai jab real services ho (khaali ho to section hide).
class ServicesStrip extends StatelessWidget {
  const ServicesStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      final services = homeCtrl.homeServices;
      if (services.isEmpty) {
        return const SizedBox.shrink();
      }
      final appCtrl = homeCtrl.appCtrl;
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: AppScreenUtil().screenWidth(15),
            vertical: AppScreenUtil().screenHeight(15)),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: services.map((svc) {
              return Container(
                width: AppScreenUtil().screenWidth(220),
                margin: EdgeInsets.only(
                    right: AppScreenUtil().screenWidth(10)),
                padding: EdgeInsets.symmetric(
                    horizontal: AppScreenUtil().screenWidth(12),
                    vertical: AppScreenUtil().screenHeight(12)),
                decoration: BoxDecoration(
                  color: appCtrl.appTheme.greyLight25,
                  borderRadius: BorderRadius.circular(
                      AppScreenUtil().borderRadius(8)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (svc.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppScreenUtil().borderRadius(6)),
                        child: imageNetwork(
                            url: svc.image,
                            width: AppScreenUtil().screenWidth(36),
                            height: AppScreenUtil().screenHeight(36),
                            fit: BoxFit.contain),
                      )
                    else
                      Icon(Icons.local_shipping_outlined,
                          size: AppScreenUtil().size(30),
                          color: appCtrl.appTheme.primary),
                    const Space(8, 0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LatoFontStyle(
                            text: svc.title,
                            fontSize: FontSizes.f13,
                            fontWeight: FontWeight.w700,
                            maxLines: 2,
                            color: appCtrl.appTheme.blackColor,
                          ),
                          if (svc.description.isNotEmpty) ...[
                            const Space(0, 3),
                            LatoFontStyle(
                              text: svc.description,
                              fontSize: FontSizes.f11,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              color: appCtrl.appTheme.contentColor,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}
