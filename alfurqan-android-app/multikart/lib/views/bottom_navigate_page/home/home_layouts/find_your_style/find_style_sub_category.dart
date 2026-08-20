import '../../../../../config.dart';

class FindStyleSubCategory extends StatelessWidget {
  const FindStyleSubCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(builder: (homeCtrl) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: homeCtrl.findStyleCategoryCategoryWiseList.length,
        itemBuilder: (context, index) {
          final item = homeCtrl.findStyleCategoryCategoryWiseList[index];
          return FindStyleListCard(
            data: item,
            index: index,
            source: "findStyle",
            // real product detail page khule (demo nahi)
            onTap: () => homeCtrl.openProductById(item.id),
          );
        },
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
          childAspectRatio: MediaQuery.of(context).size.width /
              (MediaQuery.of(context).size.height /
                  (MediaQuery.of(context).size.width < 370
                      ? 1.2
                      : MediaQuery.of(context).size.width < 380
                          ? 1.0
                          : MediaQuery.of(context).size.width > 400
                              ? 1.2
                              : 1.3)),
        ),
      );
    });
  }
}
