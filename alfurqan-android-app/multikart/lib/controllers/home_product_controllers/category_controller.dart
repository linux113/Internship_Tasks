import 'package:multikart/models/category_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

import '../../config.dart';

class CategoryController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  List<CategoryApiModel> categoryList = [];

  @override
  void onReady() {
    // TODO: implement onReady
    getData();
    super.onReady();
  }

  //get data list (GetTopCategory api)
  getData() async {
    appCtrl.isShimmer = true;
    appCtrl.update();

    final res = await ApiService().request<List<CategoryApiModel>>(
      endpoint: ApiEndpoints.topCategory,
      method: ApiMethod.get,
      fromJson: (json) => CategoryApiModel.listFromJson(json),
    );

    if (res.isSuccess && res.data != null) {
      categoryList = res.data!;
    }

    update();
    appCtrl.isShimmer = false;
    appCtrl.update();
    update();
  }

  /// Category tap karne par category-product page open karo, slug bhejo.
  /// (jaise https://alfurqan.ae/category/jurisprudence -> slug = "jurisprudence")
  goToCategoryProducts(CategoryApiModel category) {
    appCtrl.isNotification = true;
    appCtrl.update();
    Get.toNamed(routeName.shopPage, arguments: category.slug);
  }
}
