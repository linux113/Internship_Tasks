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
    // FIX (strict no-static): pehle yaha fashion demo similar products
    // (Blue Denim Jacket etc) load hote the — real api aane tak (ya api
    // fail hone par hamesha ke liye) user ko kapde dikhte the. Ab khaali
    // start; section empty hone par view hide kar deta hai.
    similarList = [];
    update();
    super.onReady();

    // similar products real api se lao (same category)
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
      // NAYA product aa gaya to purane product ki optimistic review atki
      // na rahe (match product id se).
      if (apiProduct?.id != args.id) _myOptimisticReview = null;
      apiProduct = args;
      product = args.toProduct();
    } else {
      apiProduct = null;
      _myOptimisticReview = null;
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
    // FIX: controller REUSE hota hai (onReady sirf pehli baar) — naye
    // product par purane product ka similar list atka rehta tha aur fetch
    // bhi dobara nahi hota tha. Ab har load par similar reset + fresh fetch.
    similarList = [];
    similarApiProducts = [];
    update();
    if (apiProduct != null) {
      fetchSimilarProducts();
      // Reviews HAMESHA server se fresh lao (10/09 strict-fix — "count 1
      // dikhta hai par neeche review nahi"): home ke compact payloads me
      // review fields hote hi nahi (isliye "Customer Reviews (null)"
      // aata tha) aur list-ke review fields stale ho sakte hai. Ye api
      // GUEST ke liye bhi open hai (live verify) — har entry point par
      // sahi count/list/stars milenge.
      fetchLiveReviews();
    }
  }

  /// Submit ke turant baad ka optimistic review — server approval queue
  /// me rehne par bhi user ko uski entry dikhani hai. fetchLiveReviews
  /// isko merge/dedupe karta hai.
  Reviews? _myOptimisticReview;

  /// Product ke reviews SERVER se fresh lao:
  /// GET /api/Review/GetProductReview?id=<pid> (10/09 live verify —
  /// GUEST bina token bhi {code:200, data:{data:[...]}} paata hai).
  /// Ye teen cheezein theek karta hai:
  ///  1. "Customer Reviews (null)" — count kabhi null nahi rahega.
  ///  2. Header "(N ratings)" aur neeche ki list HAMESHA ek hi source se.
  ///  3. Home/compact payloads (review fields gayab) se khulne par bhi
  ///     reviews dikhte hai.
  /// Meri optimistic entry tab tak upar rakho jab tak server list me na
  /// aa jaye (match = same text + same stars — save hone par duplicate
  /// apne aap hat jati hai).
  Future<void> fetchLiveReviews() async {
    final pid = apiProduct?.id ?? 0;
    if (pid <= 0) return;
    try {
      final res = await ApiService().request<dynamic>(
        endpoint: ApiEndpoints.productReviews,
        method: ApiMethod.get,
        queryParams: {'id': pid},
        fromJson: (json) => json,
      );
      if (!res.isSuccess || res.data == null) return;
      // Shape: { code, isSuccess, data: { current_page.., data: [...] } }
      // (paginator ke andar list hoti hai), par safety ke liye seedhi
      // list bhi accept karo.
      dynamic node = res.data;
      List<dynamic> items = const [];
      if (node is Map && node['data'] is List) {
        items = node['data'] as List<dynamic>;
      } else if (node is List) {
        items = node;
      }
      int myId = 0;
      try {
        final raw = LocalStorage().read('id');
        myId = raw is num
            ? raw.toInt()
            : (int.tryParse(raw?.toString() ?? '') ?? 0);
      } catch (_) {}
      final myName =
          (LocalStorage().read('name') ?? '').toString().trim();

      final fetched = <Reviews>[];
      for (final e in items) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final consumer = m['consumer'] ?? m['user'] ?? m['created_by'];
        var name = consumer is Map
            ? (consumer['name'] ?? consumer['Name'] ?? consumer['email'] ?? '')
                .toString()
                .trim()
            : '';
        final cid = m['consumer_id'] ?? m['consumerId'] ?? m['user_id'];
        // Server consumer:null bhejta hai — meri apni review ka naam mujhe
        // pata hai (local profile), to wahi dikhao.
        if (name.isEmpty &&
            myId > 0 &&
            cid != null &&
            cid.toString() == myId.toString() &&
            myName.isNotEmpty) {
          name = myName;
        }
        if (name.isEmpty) name = 'customer'.tr;
        // created_at ISO "2026-09-10T21:38:01..." -> dd/MM/yyyy
        final rawDate = (m['created_at'] ??
                m['Created_at'] ??
                m['createdAt'] ??
                m['date'] ??
                '')
            .toString();
        var date = rawDate;
        if (rawDate.length >= 10) {
          final p = rawDate.substring(0, 10).split('-');
          if (p.length == 3 && p[0].length == 4) {
            date = '${p[2]}/${p[1]}/${p[0]}';
          } else if (rawDate.length >= 10) {
            date = rawDate.substring(0, 10);
          }
        }
        double rating = 0;
        final rv = m['rating'] ?? m['stars'];
        if (rv is num) {
          rating = rv.toDouble();
        } else {
          rating = double.tryParse(rv?.toString() ?? '') ?? 0;
        }
        fetched.add(Reviews(
          name: name,
          description:
              (m['description'] ?? m['review'] ?? m['comment'] ?? m['message'] ?? '')
                  .toString(),
          date: date,
          rating: rating,
          image: '',
          size: '',
          like: 0,
          disLike: 0,
        ));
      }

      // Meri optimistic entry server me aayi ya nahi? (match: text+stars)
      final mine = _myOptimisticReview;
      var merged = fetched;
      if (mine != null) {
        final alreadyThere = fetched.any((r) =>
            (r.description ?? '').trim() ==
                (mine.description ?? '').trim() &&
            (r.rating ?? 0) == (mine.rating ?? 0));
        if (!alreadyThere) {
          merged = <Reviews>[mine, ...fetched];
        } else {
          // Server ne dikha diya — ab optimistic copy ki zarurat nahi.
          _myOptimisticReview = null;
        }
      }

      product.reviews = merged.isEmpty ? null : merged;
      product.totalReview = merged.length;
      product.ratingPoints = merged.length.toDouble();
      // Stars = server reviews ka average (server ka rating_count field
      // aksar 0 rehta hai chahe reviews ho — trustees list hi sahi hai).
      if (merged.isNotEmpty) {
        var sum = 0.0;
        var n = 0;
        for (final r in merged) {
          final v = r.rating ?? 0;
          if (v > 0) {
            sum += v;
            n++;
          }
        }
        if (n > 0) product.rating = sum / n;
      }
      update();
    } catch (_) {}
  }

  /// USER KA SUBMITTED REVIEW turant screen par dikhao (08/09 deep-fix —
  /// "rating deta hoon phir bhi 0 rehta hai"): server review ko approval
  /// queue me rakhta hai — GetAllProductsFront tab tak us product ke
  /// reviews[]/reviews_count me nahi dikhata, isliye sirf server data par
  /// bharosa karne se page par hamesha "(0 ratings)" hi rehta. Review
  /// server accept kar chuka hai (toast "Data has been save"), isliye UI
  /// me USKI entry turant top par dikhao: count+1, stars (agar server
  /// avg 0 hai to uski rating), Customer Reviews me uska naam/tarikh/text.
  /// Page reopen par fresh server data aata hai — duplicate nahi banta
  /// (approval ke baad count server se hi aata hai).
  void applyMyReview({required double rating, required String text}) {
    final p = product;
    p.totalReview = (p.totalReview ?? 0) + 1;
    p.ratingPoints = (p.ratingPoints ?? 0) + 1;
    if ((p.rating ?? 0) <= 0) p.rating = rating;
    String name = (LocalStorage().read('name') ?? '').toString().trim();
    if (name.isEmpty) name = 'you'.tr;
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
    final mine = Reviews(
      name: name,
      description: text,
      date: date,
      rating: rating,
      image: '',
      size: '',
      like: 0,
      disLike: 0,
    );
    // 10/09 strict-fix: is entry ko yaad rakho — fetchLiveReviews isko
    // server list me aane tak top par rakhega aur aane par dedupe kar
    // dega (pehle optimistic entry page reopen par gayab ho jati thi).
    _myOptimisticReview = mine;
    p.reviews = <Reviews>[
      mine,
      ...?p.reviews,
    ];
    update();
    // Thodi der baad server se reconcile (review abhi approval queue me
    // ho sakti hai — dedupe logic duplicate nahi banayega).
    Future.delayed(const Duration(seconds: 2), () {
      if (apiProduct?.id != null) fetchLiveReviews();
    });
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
