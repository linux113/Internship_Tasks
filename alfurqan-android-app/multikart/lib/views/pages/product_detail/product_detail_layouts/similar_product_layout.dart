import '../../../../config.dart';
import '../../../../controllers/pages_controller/product_detail_controller.dart';
import '../../../../models/product_api_model.dart';

class SimilarProductLayout extends StatelessWidget {
  final List<HomeFindStyleCategoryModel>? data;
  final double bottom;
  const SimilarProductLayout({Key? key, this.data, this.bottom = 60})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: data!.asMap().entries.map((e) {
          return FindStyleListCard(
            data: data![e.key],
            isFit: true,
            isDiscountShow: false,
            index: e.key,
            // similar card tap -> usi real product ka detail khule.
            // FIX: pehle sirf detail-page ki similarApiProducts list dekhta
            // tha — cart page par ye list alag hoti hai isliye galat/demo
            // detail khulta tha. Ab pehle ID se match dhundhte hai, na mile
            // to home controller ke api products me id se kholte hai.
            onTap: () {
              final int cardId = data![e.key].id;
              ProductApiModel? api;
              if (Get.isRegistered<ProductDetailController>()) {
                final pc = Get.find<ProductDetailController>();
                for (final p in pc.similarApiProducts) {
                  if (p.id == cardId) {
                    api = p;
                    break;
                  }
                }
              }
              if (api == null && Get.isRegistered<HomeController>()) {
                final home = Get.find<HomeController>();
                for (final p in [
                  ...home.homeApiProductsAll,
                  ...home.newestApiProducts
                ]) {
                  if (p.id == cardId) {
                    api = p;
                    break;
                  }
                }
              }
              if (api != null) {
                Get.find<AppController>().goToProductDetail(arguments: api);
              } else if (Get.isRegistered<HomeController>()) {
                Get.find<HomeController>().openProductById(cardId);
              }
            },
          ).paddingOnly(right: AppScreenUtil().screenWidth(10));
        }).toList(),
      ),
    ).marginOnly(
        left: AppScreenUtil().screenWidth(15),
        top: AppScreenUtil().screenHeight(10),
        bottom: AppScreenUtil().screenHeight(bottom));
  }
}
