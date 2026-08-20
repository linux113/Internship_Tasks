import '../../../../config.dart';

class SizeLayout extends StatelessWidget {
  const SizeLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(builder: (filterCtrl) {
      return GridView.builder(
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: filterCtrl.sizeList.length,
        itemBuilder: (context, index) {
          return GridviewThreeLayout(
            data: filterCtrl.sizeList[index],
            index: index,
            selectIndex: filterCtrl.selectSize,
            onTap: () {
              filterCtrl.selectSize = index;
              filterCtrl.update();
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
