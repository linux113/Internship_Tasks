import '../../../../config.dart';

class RecommendedLayout extends StatelessWidget {
  const RecommendedLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SearchScreenController>(builder: (searchCtrl) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: searchCtrl.recommendedList.length,
        itemBuilder: (context, index) {
          return GridviewThreeLayout(
            data: searchCtrl.recommendedList[index],
            index: index,
            selectIndex: searchCtrl.selectRecommended,
            onTap: () {
              searchCtrl.selectRecommended = index;
              searchCtrl.update();
              // Real category chip hai (slug hai) to us category ka shop page
              // kholo — demo chip ho to kuch mat karo (khaali page na khule).
              final slug = searchCtrl.recommendedList[index]['slug']
                      ?.toString() ??
                  '';
              if (slug.isNotEmpty) searchCtrl.goToShopPage(slug);
            },
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 0,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height / (4.5)),
        ),
      );
    });
  }
}
