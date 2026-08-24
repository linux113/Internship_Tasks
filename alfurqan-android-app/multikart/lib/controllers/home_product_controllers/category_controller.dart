import 'package:multikart/models/category_api_model.dart';
import 'package:multikart/services/category_cache.dart';

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

  //get data list (NAYA home api ke Top_Category section se — purana
  // GetTopCategory api backend ne band kar diya hai)
  getData() async {
    appCtrl.isShimmer = true;
    appCtrl.update();

    await CategoryCache.ensureLoaded();
    if (CategoryCache.items.isNotEmpty) {
      categoryList = CategoryCache.items;
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
