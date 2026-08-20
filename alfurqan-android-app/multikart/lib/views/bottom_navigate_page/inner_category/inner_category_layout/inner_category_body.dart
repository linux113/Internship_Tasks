import '../../../../config.dart';

class InnerCategoryBody extends StatelessWidget {
  const InnerCategoryBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InnerCategoryController>(
      builder: (innerCtrl) {
        return SingleChildScrollView(
          child: Column(children: [
            //category info. layout
            if (innerCtrl.categoryModel != null)
              CategoryCardLayout(
                categoryModel: innerCtrl.categoryModel,
                index: innerCtrl.index,
                isEven: true,
                onTap: () async{
                  innerCtrl.appCtrl.isShimmer = true;
                  innerCtrl.appCtrl.update();
                  innerCtrl.goToShopPage(
                      innerCtrl.categoryModel!.slug.toString());
                  await Future.delayed(DurationsClass.s1);
                  innerCtrl.appCtrl.isShimmer = false;
                  innerCtrl.appCtrl.update();
                  Get.forceAppUpdate();
                },
              ),
            // FIX: purana "expandable subcategory" aur "brands" section dono
            // fashion demo data dikhate the aur unke tap par khaali demo pages
            // khulte the — bookshop app me se hata diye gaye hai.

            //trending category layout (ab real alfurqan.ae categories)
            const CommonTrendingCategory(),
            const Space(0, 10),
          ]),
        );
      }
    );
  }
}
