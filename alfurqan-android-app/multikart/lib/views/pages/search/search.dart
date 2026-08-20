import 'package:multikart/config.dart';

class Search extends StatelessWidget {
  final searchCtrl = Get.put(SearchScreenController());

  Search({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchScreenController>(builder: (_) {
      return Directionality(
          textDirection: searchCtrl.appCtrl.isRTL ||
              searchCtrl.appCtrl.languageVal == "ar"
              ? TextDirection.rtl
              : TextDirection.ltr,
        child: Scaffold(
          body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SearchWidget().searchAndBackArrow(searchCtrl.controller),
              //recent search list layout
              SearchWidget().commonText(SearchFont().recentSearch),
              ...searchCtrl.recentSearchList.map((e) {
                return RecentSearchCard(data: e);
              }).toList(),
              const Space(0,20),
              SearchWidget().commonText(SearchFont().recommendedForYou),
              //recommended list layout
              const RecommendedLayout(),
                  const Space(0,30),
              SearchWidget().commonText(SearchFont().trendingCategory),
              //trending category layout
              const CommonTrendingCategory(),
                  const Space(0,20),
              SearchWidget().commonText(SearchFont().topBrandForMultikart),

              //brand list layout
              const CommonBrandLayout()
            ]),
          ),
        ),
      );
    });
  }
}
