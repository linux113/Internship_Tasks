import 'package:multikart/config.dart';
import 'package:multikart/shimmer_layouts/category_shimmer/shop_shimmer.dart';
import 'package:multikart/views/pages/shop/shop_list_layout.dart';

class ShopPage extends StatelessWidget {
  final shopCtrl = Get.put(ShopController());

  ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ShopController>(builder: (_) {
      return Directionality(
        textDirection:
            shopCtrl.appCtrl.isRTL || shopCtrl.appCtrl.languageVal == "ar"
                ? TextDirection.rtl
                : TextDirection.ltr,
        child: PopScope(
          // FIX: pehle canPop:false tha — PopScope me onPopInvoked ka return
          // value IGNORE hota hai, isliye phone back gesture dead tha.
          canPop: true,
          child: Scaffold(
            appBar: HomeProductAppBar(
              onTap: () async {
                shopCtrl.goToHomePage();
              },
              titleChild: CommonAppBarTitle(
                // TITLE me category ka REAL NAME dikhe (url slug nahi —
                // "jurisprudence" jaise english slug user ko ajeeb lagte the)
                title: "${shopCtrl.displayName.isNotEmpty ? shopCtrl.displayName.tr : shopCtrl.name.tr} ${ShopFont().collection}",
                // pehle "2050 products" hardcoded tha — ab loaded list ka
                // REAL count dikhta hai (scroll par aur load hote hai)
                desc: "${shopCtrl.productList.length} ${ShopFont().products}",
              ),
            ),
            body: SingleChildScrollView(
                child: Column(children: [
              IntrinsicHeight(
                child: Row(
                  children: [
                    //search text box layout
                    Expanded(
                      child: SearchTextBox(
                        controller: shopCtrl.controller,
                        suffixIcon: SearchWidget().suffixIcon(),
                        prefixIcon: SearchWidget().prefixIcon(),
                      ),
                    ),
                    //filter icon layout
                    const FilterIconLayout().gestures(
                        onTap: () =>
                            Navigator.of(context).push(shopCtrl.createRoute()))
                  ],
                ),
              ),
              const Space(0, 20),
              //shop list layout
              shopCtrl.appCtrl.isShimmer
                  ? const ShopShimmer()
                  : const ShopListLayout()
            ])),
            bottomNavigationBar: CommonBottomNavigation(
                onTap: (val) => shopCtrl.bottomNavigationChange(val, context)),
          ),
        ),
      );
    });
  }
}
