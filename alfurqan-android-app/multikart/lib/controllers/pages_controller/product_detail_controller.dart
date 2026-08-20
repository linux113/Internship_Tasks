import '../../config.dart';
import '../../models/product_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../home_product_controllers/cart_controller.dart';

class ProductDetailController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  TextEditingController controller = TextEditingController();
  Product product = Product();

  /// Shop grid se aaya asli api product (AddToCart ke liye id/price yahi se milta hai).
  /// Static demo product khula ho to null rahega.
  ProductApiModel? apiProduct;
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
      apiProduct = args;
      product = args.toProduct();
    } else {
      apiProduct = null;
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

    // similar products bhi real api se lao (same category), demo list overwrite karo
    if (apiProduct != null) {
      fetchSimilarProducts();
    }
  }

  /// "You may also like" section — isi product ki category ke real products
  /// (GetAllProductsFront?category=<slug>) se bharo, current product hata kar.
  Future<void> fetchSimilarProducts() async {
    final api = apiProduct;
    if (api == null) return;

    String slug = '';
    for (final c in api.categories) {
      if ((c.slug ?? '').isNotEmpty) {
        slug = c.slug!;
        break;
      }
    }
    if (slug.isEmpty) return; // slug na mile to demo list hi chalne do

    final res = await ApiService().request<ProductListResponseModel>(
      endpoint: ApiEndpoints.productList,
      method: ApiMethod.get,
      queryParams: {
        "page": 1,
        "paginate": 8,
        "status": 1,
        "field": "created_at",
        "category": slug,
        "price": "",
        "tag": "",
        "sort": "desc",
        "sortBy": "desc",
        "rating": "",
        "attribute": "",
      },
      fromJson: (json) => ProductListResponseModel.fromJson(json),
    );

    if (res.isSuccess && res.data != null) {
      final others =
          res.data!.data.where((p) => p.id != api.id).take(6).toList();
      if (others.isNotEmpty) {
        similarList = others.map((e) => e.toFindStyleModel()).toList();
        update();
      }
    }
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

  /// "Add to Cart/Bag" button tap — real api (Cart/AddToCart) call karti hai.
  /// Success hone par cart tab (dashboard) khol deti hai, jaise pehle UI karta tha.
  Future<void> onAddToCartTap() async {
    final api = apiProduct;

    if (api == null || api.id == null) {
      // static/demo product — real cart api uske liye nahi hai
      snackBar('This is a demo product, it cannot be added to the cart.',
          context: Get.context);
      return;
    }

    final cartCtrl = Get.isRegistered<CartController>()
        ? Get.find<CartController>()
        : Get.put(CartController());

    final int qty = (product.quantity ?? 1) <= 0 ? 1 : (product.quantity ?? 1);
    final double unitPrice = api.finalPrice;

    final bool success = await cartCtrl.addToCart(
      productId: api.id!,
      variationId: null,
      quantity: qty,
      subTotal: unitPrice * qty,
      wholesalePrice: unitPrice,
    );

    if (!success) return; // error ka toast addToCart khud dikha chuka hai

    // cart (bag) tab khol do — dashboard ka index 2 cart hota hai
    appCtrl.isShimmer = true;
    appCtrl.selectedIndex = 2;
    appCtrl.goToHome();
    Get.toNamed(routeName.dashboard);
    await Future.delayed(DurationsClass.s1);
    appCtrl.isShimmer = false;
    Get.forceAppUpdate();
  }
}
