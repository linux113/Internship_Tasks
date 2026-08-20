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
