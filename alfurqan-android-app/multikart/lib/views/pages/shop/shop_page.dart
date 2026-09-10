import 'package:multikart/config.dart';
import 'package:multikart/shimmer_layouts/category_shimmer/shop_shimmer.dart';
import 'package:multikart/views/pages/shop/shop_list_layout.dart';
import 'package:multikart/widgets/common/loading_box.dart';

class ShopPage extends StatelessWidget {
  final shopCtrl = Get.put(ShopController());

  ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Har route-entry par arguments ke saath sync karo (See All / category
    // chip / banner) — ShopController REUSE hota hai isliye onReady dobara
    // nahi chalta; bina iske See All par PURANI (kabhi-kabhi empty) category
    // atki rehti thi: "collection 0 record" (10/09). Same args par dedupe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      shopCtrl.openCategory(Get.arguments);
    });
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
            body: RefreshIndicator(
                // Issue #6 (10/09) — neeche kheencho to products refresh.
                color: const Color(0xFF044015),
                onRefresh: () async => shopCtrl.getProducts(reset: true),
                child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
              //shop list layout — 10/09 user request: category tap karne
              //par screen BLANK rehti thi jab tak products na aa jaye
              //(isShimmer tab tak false ho chuka hota hai, isliye shimmer
              //bhi nahi dikhta tha). Ab CLEAR 3-state:
              //  1) fetch chal raha + list khaali  = green LOADER + msg
              //  2) fetch khatam + sach me khaali  = HONEST empty state
              //  3) data aa gaya                   = product grid
              shopCtrl.appCtrl.isShimmer
                  ? const ShopShimmer()
                  : (shopCtrl.isLoadingProducts &&
                          shopCtrl.productList.isEmpty)
                      ? LoadingBox(
                          messageKey: 'loadingProducts',
                          height: AppScreenUtil().screenHeight(320))
                      : (!shopCtrl.isLoadingProducts &&
                              shopCtrl.productList.isEmpty)
                          ? SizedBox(
                              height: AppScreenUtil().screenHeight(320),
                              child: Center(
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                    Icon(Icons.inventory_2_outlined,
                                        size: AppScreenUtil().size(40),
                                        color: shopCtrl
                                            .appCtrl.appTheme.contentColor),
                                    const Space(0, 12),
                                    LatoFontStyle(
                                        text: 'noProductsFound'.tr,
                                        fontSize: FontSizes.f14,
                                        color: shopCtrl
                                            .appCtrl.appTheme.contentColor),
                                  ])))
                          : const ShopListLayout()
            ]))),
            bottomNavigationBar: CommonBottomNavigation(
                onTap: (val) => shopCtrl.bottomNavigationChange(val, context)),
          ),
        ),
      );
    });
  }
}
