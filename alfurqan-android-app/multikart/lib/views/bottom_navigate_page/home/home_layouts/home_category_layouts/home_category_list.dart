import '../../../../../config.dart';

class HomeCategoryList extends StatelessWidget {
  const HomeCategoryList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (appCtrl) {
        return GetBuilder<HomeController>(builder: (homeCtrl) {
          return SizedBox(
            // 22/09 (Lalit — category circle frame ke bahar): gol photo ab
            // 70px hai (pehle 62) — lambe Arabic naam 2 lines lene par bhi
            // column (70+6+~30=106) row se bahar na nikle, isliye height
            // 100 -> 106. ListView hardEdge clipping se bhi circle/label
            // cut nahi honge.
            height: AppScreenUtil().size(106),
            child: ListView.builder(
              itemCount: homeCtrl.homeCategoryList.length,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return HomeCategoryData(
                  data: homeCtrl.homeCategoryList[index],
                  index: index,
                );
              },
            ),
          );
        });
      }
    );
  }
}
