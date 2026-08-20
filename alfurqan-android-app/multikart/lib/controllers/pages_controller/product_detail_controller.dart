import '../../config.dart';
import '../../models/product_api_model.dart';

class ProductDetailController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController controller = TextEditingController();
  Product product = Product();
  List<Images> imagesList = [];
  int current = 0;
  List reviewList = [];
  int currentLast = 0;
  bool isNotData = false;
  int selectedColor = 0;
  int selectedSize = 0;
  bool isCartPage = false;
  final CarouselController sliderController = CarouselController();
  List<HomeFindStyleCategoryModel> similarList = [];
  int colorSelected = 1;

  @override
  void onReady() {
    // Get.arguments me agar real product (ProductApiModel) aaya ho — jaise
    // ab shop grid me image/card tap karne par aata hai — to wahi dikhao,
    // warna purana static demo product fallback ke roop me chalega.
    final args = Get.arguments;
    if (args is ProductApiModel) {
      product = args.toProduct();
    } else {
      product = productList;
    }
    similarList = AppArray().similarProductList;

    imagesList = [];
    final List<Images> allImages = product.images ?? [];
    for (var i = 0; i < allImages.length; i++) {
      // real api products me colorId hota hi nahi (koi color-variant nahi),
      // isliye aisi images ko bhi dikhao — pehle sirf exact colorId match
      // wali images add hoti thi, jisse real product ki image kabhi
      // dikhti hi nahi thi.
      if (allImages[i].colorId == null || colorSelected == allImages[i].colorId) {
        imagesList.add(allImages[i]);
      }
    }
    update();
    super.onReady();
  }

  //on quantity increase
  quantityIncrease() {
    int val = product.quantity!;
    val++;
    product.quantity = val;
    update();
  }

  //on quantity decrease
  quantityDecrease() {
    int val =product.quantity!;
    val--;
    if (product.quantity! <= 1) {
      product.quantity = 1;
    } else {
      product.quantity = val;
    }
    update();
  }
}
