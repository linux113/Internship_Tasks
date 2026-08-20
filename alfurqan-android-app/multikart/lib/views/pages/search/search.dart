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
              // Jab tak user type nahi karta -> purana (recent/recommended) layout,
              // type karte hi -> real api se filtered products grid.
              if (searchCtrl.query.isNotEmpty) ...[
                if (searchCtrl.isSearchLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (searchCtrl.searchResults.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Center(
                      child: LatoFontStyle(
                          text: "No products found for '${searchCtrl.query}'",
                          fontSize: FontSizes.f14,
                          color: searchCtrl.appCtrl.appTheme.contentColor),
                    ),
                  )
                else
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: searchCtrl.searchResults.length,
                    itemBuilder: (context, index) {
                      return FindStyleListCard(
                        data: searchCtrl.searchResults[index],
                        index: index,
                        // tap karte hi wahi real product detail page pe jaye
                        onTap: () => searchCtrl.appCtrl.goToProductDetail(
                            arguments: searchCtrl.searchResultApi[index]),
                      );
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 5,
                      mainAxisSpacing: 5,
                      childAspectRatio: MediaQuery.of(context).size.width /
                          (MediaQuery.of(context).size.height / 1.2),
                    ),
                  ).marginSymmetric(
                      horizontal: AppScreenUtil().screenWidth(15),
                      vertical: AppScreenUtil().screenHeight(10)),
              ] else ...[
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
                //trending category layout (ab real alfurqan.ae categories)
                const CommonTrendingCategory(),
                    const Space(0,20),
                // FIX: "Top Brands on Multikart" section fashion demo brands
                // dikhata tha — bookstore app se hata diya gaya hai.
              ]
            ]),
          ),
        ),
      );
    });
  }
}
