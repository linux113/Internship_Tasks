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
            // similar card tap -> usi real product ka detail khule
            onTap: () {
              ProductApiModel? api;
              if (Get.isRegistered<ProductDetailController>()) {
                final pc = Get.find<ProductDetailController>();
                if (e.key < pc.similarApiProducts.length) {
                  api = pc.similarApiProducts[e.key];
                }
              }
              Get.find<AppController>().goToProductDetail(arguments: api);
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
