import '../../../config.dart';

class ShopListLayout extends StatelessWidget {
  const ShopListLayout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  GetBuilder<ShopController>(
      builder: (shopCtrl) {
        // ab real GetAllProductsFront wali list use ho rahi hai
        // (pehle static `homeShopPageList` dikhta tha).
        return GridView.builder(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: shopCtrl.productList.length,
          itemBuilder: (context, index) {
            final product = shopCtrl.productList[index];
            return FindStyleListCard(
              data: product.toFindStyleModel(),
              index: index,
              // image/card tap karte hi wahi tapped product detail page pe jaye
              onTap: () => shopCtrl.appCtrl.goToProductDetail(arguments: product),
            );
          },
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 0,
            childAspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.height / (1.17)),
          ),
        ).marginSymmetric(horizontal: AppScreenUtil().screenWidth(15));
      }
    );
  }
}
