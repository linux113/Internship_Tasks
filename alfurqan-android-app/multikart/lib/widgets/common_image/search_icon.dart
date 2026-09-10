import '../../config.dart';

class SearchIcon extends StatelessWidget {
  const SearchIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(builder: (appCtrl) {
      // 10/09 redesign (user: "home search icon fix, category section
      // jaisa"): (1) icon ab brand-green rounded button me dikhta hai —
      // home AUR category dono jagah same, saaf-saaf nazar aata hai;
      // (2) tap karne par selectedIndex BADALNA band — pehle tap karte
      // hi piche bottom-nav ka highlight chupke se CATEGORY tab par chala
      // jata tha (search page band hote hi galti se category khulti thi);
      // ab seedha REAL search page khulta hai, wapas aane par wahi tab.
      return Container(
        width: AppScreenUtil().size(36),
        height: AppScreenUtil().size(36),
        decoration: BoxDecoration(
          color: const Color(0xFF044015),
          borderRadius:
              BorderRadius.circular(AppScreenUtil().borderRadius(9)),
        ),
        child: Center(
          child: Icon(
            Icons.search_rounded,
            size: AppScreenUtil().size(20),
            color: appCtrl.appTheme.whiteColor,
          ),
        ),
      ).gestures(onTap: () {
        Get.toNamed(routeName.search);
      });
    });
  }
}
