import '../../config.dart';
import '../../models/product_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../home_product_controllers/cart_controller.dart';
import '../home_product_controllers/wishlist_controller.dart';

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

  /// similar products ke asli api objects (similar card tap -> real detail ke liye)
  List<ProductApiModel> similarApiProducts = [];
  int colorSelected = 1;

  @override
  void onReady() {
    loadProduct(Get.arguments);
    similarList = AppArray().similarProductList;
    update();
    super.onReady();

    // similar products bhi real api se lao (same category), demo list overwrite karo
    if (apiProduct != null) {
      fetchSimilarProducts();
    }
  }

  /// Product load karo. GetX SAME controller ko reuse karta hai jab detail
  /// page dubara khulta hai (onReady sirf pehli baar chalta hai) — isliye
  /// ye method alag rakha hai aur appCtrl.goToProductDetail har naye
  /// product pe isko call karta hai. Iske bina purana/"demo" product hi
  /// atka rehta tha aur AddToCart "demo product" wali error dikhata tha.
  /// Detail page body ka ScrollController — similar product tap par naya
  /// product SAME page me load hota hai (nayi route push block ho jati hai),
  /// isliye page ko TOP par scroll karna zaroori hai.
  final ScrollController productScroll = ScrollController();

  void loadProduct(dynamic args) {
    if (args is ProductApiModel) {
      apiProduct = args;
      product = args.toProduct();
    } else {
      apiProduct = null;
      product = productList; // purana static demo product fallback
    }

    // similar product se naya product load hua to page TOP par le jao
    try {
      if (productScroll.hasClients && productScroll.positions.length == 1) {
        productScroll.jumpTo(0);
      }
    } catch (_) {}

    imagesList = [];
    final List<Images> allImages = product.images ?? [];
    for (var i = 0; i < allImages.length; i++) {
      // real api products me colorId hota hi nahi — aisi images ko bhi dikhao
      if (allImages[i].colorId == null ||
          colorSelected == allImages[i].colorId) {
        imagesList.add(allImages[i]);
      }
    }
    update();
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
    // FIX: naye home api ke compact products me category info nahi hoti —
    // slug na mile to demo fashion list mat dikhao; uski jagah newest
    // products ko hi "similar" bana do (kam se kam BOOKS hi dikhenge).
    final res = await ApiService().request<ProductListResponseModel>(
      endpoint: ApiEndpoints.productList,
      method: ApiMethod.get,
      queryParams: {
        "page": 1,
        "paginate": 8,
        "status": 1,
        "field": "created_at",
        // slug mila to same-category, nahi to saare newest
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
        similarApiProducts = others;
        similarList = others.map((e) => e.toFindStyleModel()).toList();
        update();
      }
    }
  }

  /// Detail page ka WISHLIST button — pehle SIRF wishlist tab par le jata
  /// tha, product save hi nahi hota tha (isliye wishlist page khaali dikhti
  /// thi). Ab product pehle wishlist me SAVE hota hai (local + logged-in ho
  /// to server par bhi), phir wishlist tab khulti hai — waha item dikhega.
  Future<void> addToWishlistAndOpen() async {
    final api = apiProduct;
    if (api != null && api.id != null) {
      String discountLabel = '';
      final double price = api.price ?? 0;
      final double selling = api.finalPrice;
      if (price > 0 && selling > 0 && selling < price) {
        discountLabel =
            '${(((price - selling) / price) * 100).round()}%';
      }
      await WishlistController.saveWishlistItem(
        HomeDealOfTheDayModel(
          id: api.id!,
          name: api.name ?? '',
          image: api.thumbnail?.url ?? '',
          byWhom: 'مكتبة الفرقان',
          discount: discountLabel,
          isFav: true,
          mrp: selling, // selling (bold)
          totalPrice: price, // original (struck)
          isTrending: false,
        ),
      );
      if (Get.isRegistered<WishlistController>()) {
        Get.find<WishlistController>().refreshFromStorage();
      }
      snackBar('Added to wishlist');
    }
    // wishlist tab khol do (purana behavior) — ab waha item bhi milega
    appCtrl.isShimmer = true;
    appCtrl.selectedIndex = 3;
    appCtrl.goToHome();
    Get.toNamed(routeName.dashboard);
    await Future.delayed(DurationsClass.s1);
    appCtrl.isShimmer = false;
    Get.forceAppUpdate();
  }

  //on quantity increase
  quantityIncrease() {
    // FIX: `product.quantity!` agar null hua to app crash ho jati thi.
    product.quantity = (product.quantity ?? 1) + 1;
    update();
  }

  //on quantity decrease
  quantityDecrease() {
    final int val = product.quantity ?? 1;
    product.quantity = val <= 1 ? 1 : val - 1;
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

    // Cart (bag) tab khol do — dashboard ka index 2 cart hota hai.
    // FIX: pehle purane dashboard ke UPAR ek naya dashboard push ho jata tha
    // (back button dabane par dashboard ke andar dashboard dikhta tha).
    // Ab stack ko wapas dashboard tak pop karte hai aur cart tab select karte hai.
    Get.until((route) =>
        route.settings.name == routeName.dashboard || route.isFirst);
    appCtrl.selectedIndex = 2;
    appCtrl.goToHome();
    appCtrl.update();
    Get.forceAppUpdate();
  }
}
