import 'package:multikart/models/cart_api_model.dart';
import 'package:multikart/models/json_parse_utils.dart';
import 'package:multikart/models/product_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';
import 'package:multikart/services/tax_service.dart';
import 'package:multikart/utilities/address_store.dart';

import '../../config.dart';
import 'home_controller.dart';
import 'wishlist_controller.dart';

class CartController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  final storage = LocalStorage();
  CartModel? cartModelList;
  List<HomeFindStyleCategoryModel> similarList = [];

  // ---------------- Real cart (AddToCart / GetCart) ----------------
  CartApiModel? cartApiModel;
  bool isCartLoading = false;

  // ============ PERSISTENT CART SNAPSHOT (06/09 4pm glitch) ============
  // ROOT: server ka GetCart kabhi-kabhi KHAALI deta hai jabki user cart
  // me items dikh rahe hote hai (intermittent window — pichli versions
  // me bhi isi flake ki wajah se double-verify banana pada tha). Aur
  // getCart ka success-empty result in-memory models ko NULL kar deta
  // hai — placeOrder tak kuch nahi bachta ("first time empty, back karke
  // aao to chalta hai" glitch). Ab har VERIFIED non-empty cart ka
  // timestamped snapshot storage me rakhte hai; placeOrder isi se rescue
  // karta hai. Empty server response snapshot ko CLEAR NAHI karta (flake
  // ho sakta hai) — sirf intentional clears: order success, verified
  // remove-to-empty, 30min age, ya doosra user.
  static const String _snapKey = 'cart_snapshot_v2';
  static const String _snapClearedKey = 'cart_snapshot_v2_cleared';

  static Future<void> saveCartSnapshot({
    required int userId,
    required String total,
    required List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> items = const [],
  }) async {
    final s = LocalStorage();
    await s.write(_snapKey, <String, dynamic>{
      'u': userId,
      'ts': DateTime.now().millisecondsSinceEpoch,
      'total': total,
      'products': products,
      'items': items,
    });
    await s.write(_snapClearedKey, false);
  }

  static Future<void> clearCartSnapshot() async {
    await LocalStorage().write(_snapClearedKey, true);
  }

  /// placeOrder ka rescue source — same user + 30min ke andar + cleared
  /// nahi. null = rescue possible nahi (sach me cart khaali maano).
  static Map<String, dynamic>? readCartSnapshot(int userId) {
    final s = LocalStorage();
    if ((s.read(_snapClearedKey) ?? true) == true) return null;
    final raw = s.read(_snapKey);
    if (raw is! Map) return null;
    final m = Map<String, dynamic>.from(raw);
    if ((int.tryParse(m['u']?.toString() ?? '-1') ?? -1) != userId) {
      return null;
    }
    final ts = int.tryParse(m['ts']?.toString() ?? '0') ?? 0;
    if (DateTime.now().millisecondsSinceEpoch - ts >
        const Duration(minutes: 30).inMilliseconds) {
      return null;
    }
    final prods = (m['products'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .where((p) =>
                (int.tryParse(p['product_id']?.toString() ?? '0') ?? 0) >
                    0 &&
                (int.tryParse(p['quantity']?.toString() ?? '0') ?? 0) > 0)
            .toList() ??
        const <Map<String, dynamic>>[];
    if (prods.isEmpty) return null;
    final items = (m['items'] as List?)
            ?.whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList() ??
        const <Map<String, dynamic>>[];
    return {
      'products': prods,
      'items': items,
      'total': m['total']?.toString() ?? '0',
    };
  }

  /// getCart ke VERIFIED non-empty result ko persist karo (user id storage
  /// se). Empty par KUCH NAHI (flake-guard — clear sirf intentional).
  Future<void> _persistIfNonEmpty(CartApiModel apiCart) async {
    final liveLines = apiCart.items
        .where((l) => (l.quantity ?? 0) > 0 && (l.productId ?? 0) > 0)
        .toList();
    if (liveLines.isEmpty) return;
    final rawUid = storage.read('id');
    final uid = rawUid is num
        ? rawUid.toInt()
        : (int.tryParse(rawUid?.toString() ?? '') ?? 0);
    await CartController.saveCartSnapshot(
      userId: uid,
      total: cartModelList?.totalAmount?.toString() ?? '0',
      products: [
        for (final l in liveLines)
          {
            'product_id': l.productId ?? 0,
            'variation_id': l.variationId,
            'quantity': l.quantity ?? 1,
          }
      ],
      items: [
        for (final e in (cartModelList?.cartList ?? []))
          {
            'name': e.name ?? '',
            'image': e.image ?? '',
            'qty': int.tryParse(RegExp(r'(\d+)')
                        .firstMatch(e.byWhom ?? '')
                        ?.group(1) ??
                    '') ??
                1,
            'price': e.mrp ?? 0,
          }
      ],
    );
  }

  @override
  void onReady() {
    // Pehle yaha static demo cartList dikhti thi — ab seedha real
    // api (Cart/GetCart) ka data dikhayenge. Jab tak response nahi
    // aata, shimmer dikhate hai.
    appCtrl.isShimmer = true;
    appCtrl.update();
    update();
    getCart();
    loadSimilarProducts();
    super.onReady();
  }

  /// "You May also Like" — pehle DEMO fashion products (Blue Denim Jacket /
  /// Party Wear Jumpshuit) dikhte the. Ab REAL products: pehle home ke loaded
  /// api products se, warna newest products api se.
  Future<void> loadSimilarProducts() async {
    List<ProductApiModel> pool = [];
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      pool = [...home.homeApiProductsAll, ...home.newestApiProducts];
    }
    if (pool.isEmpty) {
      try {
        final res = await ApiService().request<ProductListResponseModel>(
          endpoint: ApiEndpoints.productList,
          method: ApiMethod.get,
          queryParams: {
            "page": 1,
            "paginate": 8,
            "status": 1,
            "field": "created_at",
            "price": "",
            "category": "",
            "tag": "",
            "sort": "desc",
            "sortBy": "desc",
            "rating": "",
            "attribute": "",
          },
          fromJson: (json) => ProductListResponseModel.fromJson(json),
        );
        if (res.isSuccess && res.data != null) pool = res.data!.data;
      } catch (_) {}
    }
    // cart me jo already items hai unhe suggestions se hata do
    final cartIds = (cartModelList?.cartList ?? [])
        .map((e) => e.id)
        .toSet();
    final seen = <int>{};
    final suggestions = <ProductApiModel>[];
    for (final p in pool) {
      if (p.id == null || cartIds.contains(p.id) || !seen.add(p.id!)) continue;
      suggestions.add(p);
      if (suggestions.length >= 8) break;
    }
    if (suggestions.isNotEmpty) {
      similarList = suggestions.map((e) => e.toFindStyleModel()).toList();
      update();
    }
  }

  /// Cart item ka "Move to wishlist" — ab asli wishlist me save hota hai
  /// (local + logged-in ho to server par bhi), sirf bottomsheet text nahi.
  Future<void> moveToWishlist(HomeDealOfTheDayModel? item) async {
    if (item == null || item.id == 0) return;
    await WishlistController.saveWishlistItem(item);
    if (Get.isRegistered<WishlistController>()) {
      Get.find<WishlistController>().refreshFromStorage();
    }
    snackBar(CommonTextFont().moveToWishList);
  }

  /// Static demo cart (`cartList` from cart_array) ke instruction
  /// sections ko borrow kar lo — ye sirf UI ke icons/text hai.
  List<DeliveryInstructionModel>? get _demoDeliveryInstruction =>
      cartList.deliveryInstruction;
  List<DeliveryChargesInstruction>? get _demoDeliveryCharges =>
      cartList.deliveryChargesInstruction;

  /// Cart me product add karna (Cart/AddToCart)
  /// [wholesalePrice] optional - na ho to 0 bhej dena.
  /// Return = true agar cart me item CONFIRM ho gaya, warna false.
  ///
  /// MULTI-ITEM FIX (user complaint: "ek se zyada add to cart nahi hote" —
  /// doosra product add karte hi pehla GAYAB ho jata tha) — do bug the:
  ///  1) har add par SIRF nayi line bheji jati thi; is backend ka AddToCart
  ///     poora cart REPLACE kar deta hai, jisse purane items mit jaate the.
  ///  2) consumer_id / created_by_id kabhi nahi bhejte the — server ko
  ///     pata hi nahi chalta tha ki cart KIS user ka hai.
  /// Ab DUAL-SEMANTIC safe flow (backend "replace" ho ya "merge", dono par
  /// sahi — aur merge-backend par kabhi duplicate/qty-double nahi hoga):
  ///  A) FRESH GetCart se live snapshot,
  ///  B) SIRF delta (nayi/बढ़ी hui) line bhejo + created_by_id,
  ///  C) GetCart se VERIFY: naya product AAYA *aur* purane BACHE hain?
  ///     — naya hai + purane gayab => backend REPLACE karta hai: ab POORA
  ///       merged array (purane original + nayi FINAL qty line) bhej kar
  ///       dobara verify.
  ///  D) sab fail -> HONEST toast (fake success nahi).
  Future<bool> addToCart({
    required int productId,
    int? variationId,
    required int quantity,
    required double subTotal,
    double wholesalePrice = 0,
  }) async {
    if (quantity <= 0) quantity = 1;
    if (subTotal <= 0) subTotal = wholesalePrice * quantity;
    isCartLoading = true;
    update();

    final bool loggedIn = (storage.read(Session.isLogin) ?? false) == true;
    int? userId;
    final rawId = storage.read('id');
    if (rawId is num) {
      userId = rawId.toInt();
    } else {
      userId = int.tryParse(rawId?.toString() ?? '');
    }

    Map<String, dynamic> line({required int id, required int q, required double sub}) => {
          "id": id,
          "product_id": productId,
          "variation_id": variationId,
          if (userId != null) "consumer_id": userId,
          "quantity": q,
          "sub_total": sub,
          "wholesale_price": wholesalePrice,
        };

    // ---- STEP A: fresh LIVE snapshot (logged-in user ka server cart) ----
    List<CartItemModel> liveLines = const <CartItemModel>[];
    if (loggedIn) {
      try {
        final fresh = await ApiService().request<CartApiModel>(
          endpoint: ApiEndpoints.getCart,
          method: ApiMethod.get,
          fromJson: (json) => CartApiModel.fromJson(json),
        );
        if (fresh.isSuccess && fresh.data != null) {
          cartApiModel = fresh.data;
          liveLines = fresh.data!.items;
        }
      } catch (_) {}
      if (liveLines.isEmpty && cartApiModel != null) {
        liveLines = List<CartItemModel>.from(cartApiModel!.items);
      }
    }
    final alive = liveLines.where((l) => (l.quantity ?? 0) > 0).toList();
    final prevPids = alive.map((l) => l.productId ?? -1).toSet();

    // same product (+ same variation) pehle se cart me hai?
    CartItemModel? existing;
    for (final l in alive) {
      if ((l.productId ?? -1) == productId &&
          (l.variationId ?? 0) == (variationId ?? 0)) {
        existing = l;
        break;
      }
    }
    final double unit = quantity > 0 ? subTotal / quantity : subTotal;

    String firstMsg = '';

    // ---- STEP B/C helpers ----
    Future<void> send(Map<String, dynamic> body) async {
      try {
        final r = await ApiService().request<CartApiModel>(
          endpoint: ApiEndpoints.addToCart,
          method: ApiMethod.post,
          data: body,
          fromJson: (json) => CartApiModel.fromJson(json),
        );
        if (firstMsg.isEmpty) firstMsg = r.message;
      } catch (_) {}
    }

    /// Verify: naya product LIVE hai AUR saare purane products bhi LIVE hai?
    Future<bool> verify() async {
      try {
        final res = await ApiService().request<CartApiModel>(
          endpoint: ApiEndpoints.getCart,
          method: ApiMethod.get,
          fromJson: (json) => CartApiModel.fromJson(json),
        );
        if (res.isSuccess && res.data != null) {
          cartApiModel = res.data;
          final live = res.data!.items
              .where((l) => (l.quantity ?? 0) > 0)
              .toList();
          final pids = live.map((l) => l.productId ?? -1).toSet();
          final hasNew = pids.contains(productId);
          final keptOld = prevPids.every(pids.contains);
          return hasNew && keptOld;
        }
      } catch (_) {}
      return false;
    }

    // ---- STEP B: DELTA-only body (merge-safe: purani lines NAHI bhejte,
    // warna merge-backend unki qty DOUBLE kar deta hai) ----
    double aliveSum = 0;
    for (final l in alive) {
      aliveSum += (l.subTotal ?? 0);
    }
    await send({
      "total": aliveSum - (existing?.subTotal ?? 0) + subTotal,
      if (userId != null) "created_by_id": userId,
      "items": [line(id: 0, q: quantity, sub: subTotal)],
    });

    bool ok = loggedIn ? await verify() : false;

    // FLAKY-NETWORK GUARD: merged-replace bhejne se PEHLE ek baar aur verify
    // karo. Warna merge-world me ye scenario possible tha: delta send SUCCESS
    // ho gaya par verify wala GetCart network-hiccup se fail ho gaya → hum
    // poora merged array bhej dete → naya item id:0 se DOBARA insert hokar
    // DOUBLE ho jata. Doosri verify pass ho gayi to replace bhejne ki
    // zaroorat hi nahi.
    if (!ok && loggedIn) {
      ok = await verify();
    }

    // ---- REPLACE world: purane gayab ho gaye (ya naya nahi aaya) ->
    // POORA merged array bhejo: purani ORIGINAL lines + nayi line FINAL
    // qty ke saath. Isse replace-backend me bhi poora multi-item cart
    // sahi ban jaata hai. ----
    if (!ok && loggedIn) {
      final mergedLines = <Map<String, dynamic>>[
        for (final l in alive)
          if ((l.productId ?? -1) == productId &&
              (l.variationId ?? 0) == (variationId ?? 0))
            line(
                id: l.id ?? 0,
                q: (l.quantity ?? 0) + quantity,
                sub: ((l.quantity ?? 0) + quantity) * unit)
          else
            l.toJson(),
        if (existing == null) line(id: 0, q: quantity, sub: subTotal),
      ];
      double tot = 0;
      for (final m in mergedLines) {
        tot += (m['sub_total'] as num?)?.toDouble() ?? 0;
      }
      await send({
        "total": tot,
        if (userId != null) "created_by_id": userId,
        "items": mergedLines,
      });
      ok = await verify();
    }

    // ---- UI ko FINAL fresh server state se settle ----
    if (loggedIn) {
      try {
        final res = await ApiService().request<CartApiModel>(
          endpoint: ApiEndpoints.getCart,
          method: ApiMethod.get,
          fromJson: (json) => CartApiModel.fromJson(json),
        );
        if (res.isSuccess && res.data != null) {
          cartApiModel = res.data;
          cartModelList = _mapApiCartToViewModel(res.data!);
        }
      } catch (_) {}
    }

    isCartLoading = false;

    if (ok) {
      if (firstMsg.isNotEmpty) socialLoginToast(firstMsg);
      update();
      return true;
    }

    // Backend cart ke liye login mangta hai — guest ko seedha login page
    // par le jao (warna samajh nahi aata Add to Cart kyu nahi ho raha).
    if (!loggedIn) {
      socialLoginToast(firstMsg.isNotEmpty
          ? firstMsg
          : 'Please login to add items to your cart.');
      update();
      Get.toNamed(routeName.login);
      return false;
    }
    socialLoginToast(
        firstMsg.isNotEmpty ? firstMsg : "itemNotAdded".tr);
    update();
    return false;
  }

  /// Cart ka latest data fetch karna (Cart/GetCart)
  // ---------------- Coupon (checkout tak carry hota hai) ----------------
  /// Coupons page par APPLY karne se code storage me save hota hai
  /// ('coupon_code') — cart screen par chip + remove option dikhate hai.
  String get appliedCoupon => storage.read('coupon_code')?.toString() ?? '';

  Future<void> clearCoupon() async {
    await storage.write('coupon_code', '');
    update();
    snackBar("couponRemoved".tr);
  }

  /// [silent] = true -> loading shimmer NAHI dikhta (background refresh).
  /// Remove/add ke baad yehi use hota hai — pehle poora screen shimmer ke
  /// saath "reload" hota tha (user complaint), ab list instantly update
  /// hoti hai aur server state chupchaap confirm ho jaati hai.
  getCart({bool silent = false}) async {
    if (!silent) {
      isCartLoading = true;
      update();
    }

    final res = await ApiService().request<CartApiModel>(
      endpoint: ApiEndpoints.getCart,
      method: ApiMethod.get,
      fromJson: (json) => CartApiModel.fromJson(json),
    );

    isCartLoading = false;
    appCtrl.isShimmer = false;
    appCtrl.update();

    if (res.isSuccess && res.data != null) {
      cartApiModel = res.data;
      cartModelList = _mapApiCartToViewModel(res.data!);
      // SNAPSHOT: verified non-empty cart persist karo (empty par chhoo
      // mat — wo FLAKY ho sakta hai; placeOrder isi snapshot se bachta
      // hai). 
      try {
        await _persistIfNonEmpty(res.data!);
      } catch (_) {}
      // Issue #4: cart/payment me TAX row — (a) tax RATES lao (Taxes/
      // GetAllTaxes, login ke saath) taaki deterministic client tax bane,
      // (b) server preview (CheckOut) se bhi lao — jo jyada authoritative
      // ho wo win. Dono fire & forget (guest/flake par chupchaap skip).
      try {
        TaxService.load().then((_) => _rebuildOrderDetail());
      } catch (_) {}
      try {
        fetchServerTax();
      } catch (_) {}
    }

    update();
  }

  /// App me pehle se loaded product pools (home api products + newest) me
  /// id se product dhundo — GetCart ke items me detail na ho to isi se
  /// naam/image/price bharte hai.
  ProductApiModel? _lookupKnownProduct(int productId) {
    if (Get.isRegistered<HomeController>()) {
      final home = Get.find<HomeController>();
      for (final p in [...home.homeApiProductsAll, ...home.newestApiProducts]) {
        if (p.id == productId) return p;
      }
    }
    return null;
  }

  /// Issue #4 (10/09 FINAL): product tax-rate se cart ka tax DETERMINISTIC
  /// compute — tax_id → rate (TaxService, Taxes/GetAllTaxes). NOTE: rates
  /// ASYNC load hote hai — cart page pehli baar khulne par rates abhi na
  /// aaye ho to ye null deta hai aur tax row chhupi rehti hai (isliye pehle
  /// sirf PAYMENT page par tax dikhta tha, cart par nahi). Isko
  /// _rebuildOrderDetail LAZILY dobara chalata hai jab rates aa chuki ho.
  /// Server ka explicit tax aane par ye value override (applyServerTotals).
  double? _computeClientTaxFromLines() {
    // VIEW items (jo user ko DIKH rahe hai) se compute — server lines
    // stale/replace ho sakti hai (remove ke turant baad sahi rahe).
    final list = cartModelList?.cartList ?? <HomeDealOfTheDayModel>[];
    if (list.isEmpty) return null;
    double sum = 0;
    bool any = false;
    for (final e in list) {
      // mapping byWhom me 'Qty: N' likhti hai — wahi se qty wapas
      int qty = 1;
      final m = RegExp(r'(\d+)').firstMatch(e.byWhom ?? '');
      if (m != null) qty = int.tryParse(m.group(1)!) ?? 1;
      if (qty <= 0) continue;
      final unitFinal = (e.mrp ?? 0); // view item ka mrp = selling price
      if (unitFinal <= 0) continue;
      ProductApiModel? product;
      if (e.id > 0) product = _lookupKnownProduct(e.id);
      // Store me ek hi active rate hai (tax_id:3 = 18%, order #1078:
      // 65 × 18% = 11.70 EXACT) — isliye singleActiveRate fallback SAFE.
      final rate = TaxService.rateFor(product?.taxId) ??
          TaxService.singleActiveRate;
      if (rate != null && rate > 0) {
        sum += (unitFinal * qty) * rate / 100;
        any = true;
      }
    }
    return any ? sum : null;
  }

  /// Real api cart (CartApiModel) ko app ke existing cart UI ke model
  /// (CartModel) me convert karna — isse cart screen ka koi bhi widget
  /// change kiye bina real api ka data dikhne lagta hai.
  /// Agar cart khaali ho to null return hota hai (EmptyCart dikhega).
  CartModel? _mapApiCartToViewModel(CartApiModel apiCart) {
    if (apiCart.items.isEmpty) return null;

    // DEDUPE-FIX: server kabhi same product ki DO live lines bhej sakta hai
    // (add/replace flows ke dauraan) — UI me wahi book do baar dikhti thi.
    // Ab (productId, variationId) ke hisaab se GROUP karke qty/subTotal jod
    // dete hai — ek product = ek row, hamesha.
    final Map<String, List<CartItemModel>> grouped = {};
    final List<String> groupOrder = [];
    for (final item in apiCart.items) {
      // GHOST-FIX: backend Remove (quantity 0) karne ke baad bhi GetCart me
      // wahi line quantity 0 ke saath bhejta rehta hai. Pehle hum use
      // dabakar wapas "Qty: 1" bana dete the — isliye wahi kitaab hamesha
      // wapas dikhti thi. Ab zero-quantity line list me hi NAHI aayegi.
      if ((item.quantity ?? 0) <= 0) continue;
      final key = '${item.productId ?? item.id ?? 0}:${item.variationId ?? 0}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
        groupOrder.add(key);
      }
      grouped[key]!.add(item);
    }

    final List<HomeDealOfTheDayModel> viewItems = [];
    double bagTotalMrp = 0; // original (mrp) prices ka sum
    double bagTotalFinal = 0; // selling prices ka sum

    for (final key in groupOrder) {
      final lines = grouped[key]!;
      final item = lines.first;
      int qty = 0;
      double lineSubSum = 0;
      for (final l in lines) {
        qty += (l.quantity ?? 0);
        lineSubSum += (l.subTotal ?? 0);
      }
      if (qty <= 0) continue;
      ProductApiModel? product = item.product;
      if ((product == null || (product.name ?? '').isEmpty) &&
          item.productId != null) {
        final found = _lookupKnownProduct(item.productId!);
        if (found != null) product = found;
      }

      // per-unit price: pehle product detail se, warna line subTotal se nikaalo
      double unitMrp = product?.price ?? 0;
      double unitFinal = product?.finalPrice ?? 0;
      if (unitFinal <= 0 && lineSubSum > 0) {
        unitFinal = lineSubSum / qty;
      }
      if (unitMrp <= 0 || unitMrp < unitFinal) unitMrp = unitFinal;

      String discountLabel = '';
      if (unitMrp > 0 && unitFinal > 0 && unitFinal < unitMrp) {
        discountLabel =
            '${(((unitMrp - unitFinal) / unitMrp) * 100).round()}%';
      }

      bagTotalMrp += unitMrp * qty;
      bagTotalFinal += unitFinal * qty;

      viewItems.add(
        HomeDealOfTheDayModel(
          id: item.productId ?? item.id ?? 0,
          name: (product?.name ?? '').isNotEmpty
              ? product!.name!
              : 'Product #${item.productId ?? ''}',
          image: product?.thumbnail?.url ?? '',
          byWhom: 'Qty: $qty',
          discount: discountLabel,
          isFav: product?.isWishlist ?? false,
          mrp: unitFinal, // main (selling) price
          totalPrice: unitMrp, // struck-through original price
          isTrending: false,
        ),
      );
    }

    final double total =
        (apiCart.total ?? 0) > 0 ? apiCart.total! : bagTotalFinal;

    // EDGE-FIX: saari lines zero-qty nikli (ya koi valid item nahi bana) to
    // EMPTY cart dikhao — warna khali CartModel se "blank" screen aati thi.
    if (viewItems.isEmpty) {
      serverTax = null;
      _clientTax = null;
      return null;
    }

    // Bag totals yaad rakho — tax row/total rebuild (_rebuildOrderDetail)
    // aur removeFromCart inhi par chalte hai (Issue #4).
    _bagTotalMrp = bagTotalMrp;
    _bagTotalFinal = bagTotalFinal;
    final model = CartModel(
      cartList: viewItems,
      totalAmount: total,
      orderDetail: const [],
      deliveryChargesInstruction: _demoDeliveryCharges,
      deliveryInstruction: _demoDeliveryInstruction,
    );
    cartModelList = model; // _rebuildOrderDetail ko list chahiye (items)
    // Deterministic client tax — server preview ka explicit tax aane tak
    // yehi dikhega (order #1078 math se EXACT match: 65 × 18% = 11.70).
    // NOTE: helper VIEW items (cartModelList) se compute karta hai, isliye
    // model set hone ke BAAD hi chalana chahiye.
    _clientTax = _computeClientTaxFromLines();
    _rebuildOrderDetail();
    return model;
  }

  // ---------------- Issue #4 (10/09): TAX row cart me bhi ----------------
  // Order detail page par order place hone ke BAAD tax dikhta hai (~18%),
  // par cart/payment par kahin nahi — user: "Tax should show in the order
  // cart as it is showing after placing the order". Server ka tax bina
  // checkout-preview (CheckOut POST) ke milta hi nahi — products me sirf
  // tax_id aata hai (rate nahi). Isliye: server preview se tax nikaalo
  // (explicit tax field ho to wo, warna serverTotal - bagTotal ka FARK —
  // ye fark hi server ka add-on hai, fake kuch bhi nahi). Preview possible
  // na ho (guest/address nahi/flake) to tax row NA dikhao.
  double? serverTax;
  double _bagTotalMrp = 0;
  double _bagTotalFinal = 0;
  bool _taxFetching = false;
  // Product tax-rate se computed tax (server preview ke BINA bhi row).
  // serverTax (server explicit) isko OVERRIDE karta hai — dono ka source
  // tag: serverTax = authoritative, _clientTax = deterministic estimate.
  double? _clientTax;

  /// Effective tax jo UI me dikhega — server explicit pehle, warna client.
  double? get _effectiveTax {
    final s = serverTax;
    if (s != null && s > 0) return s;
    final c = _clientTax;
    if (c != null && c > 0) return c;
    return null;
  }

  /// orderDetail rows (Bag total / savings / Coupon / TAX / Delivery) aur
  /// totalAmount ko latest bag totals + tax se rebuild karo.
  void _rebuildOrderDetail() {
    final m = cartModelList;
    if (m == null) return;
    final savings = _bagTotalMrp - _bagTotalFinal;
    // Tax rates async baad me aaye ho (cart khulne ke waqt na the) to ab
    // dobara compute karo — isi liye pehle cart page par Tax row chhupi
    // rehti thi jabki payment page par aa jati thi (10/09 user screenshot).
    if (_clientTax == null || _clientTax == 0) {
      final c = _computeClientTaxFromLines();
      if (c != null && c > 0) _clientTax = c;
    }
    final tax = _effectiveTax;
    // Ek hi rate wali dukkan me label ke saath rate bhi dikhao ("Tax (18%)")
    // — jaise order detail page par server dikhata hai.
    String taxTitle = "taxLabel".tr;
    final r = TaxService.singleActiveRate;
    if (tax != null && r != null) {
      final rs = r == r.roundToDouble()
          ? r.toStringAsFixed(0)
          : r.toStringAsFixed(2);
      taxTitle = '${"taxLabel".tr} ($rs%)';
    }
    m.orderDetail = [
      OrderDetail(title: "Bag total".tr, value: _bagTotalMrp),
      if (savings > 0) OrderDetail(title: "Bag savings".tr, value: savings),
      OrderDetail(title: "Coupon Discount".tr, value: "Apply Coupon".tr),
      if (tax != null) OrderDetail(title: taxTitle, value: tax),
      OrderDetail(title: "Delivery".tr, value: 0.0),
    ];
    m.totalAmount = _bagTotalFinal + (tax ?? 0);
    update();
  }

  /// Server (CheckOut preview) se tax nikaal kar cart/payment me dikhao.
  /// CheckoutController ka preview bhi isi ko apply karta hai
  /// (applyServerTotals), taaki payment page par bhi row aa jaye.
  void applyServerTotals(double serverTotal, double? explicitTax) {
    if (cartModelList == null) return;
    final t = (explicitTax != null && explicitTax > 0)
        ? explicitTax
        : (serverTotal > _bagTotalFinal
            ? serverTotal - _bagTotalFinal
            : null);
    if (t == null) return;
    // Server ka value AUTHORITATIVE hai — client estimate (same bhi ho to)
    // ab server par switch kar do. Same value par rebuild skip.
    if (serverTax != null && (t - serverTax!).abs() < 0.001) return;
    if (serverTax == null &&
        _clientTax != null &&
        (t - _clientTax!).abs() < 0.001) {
      serverTax = t; // client estimate server se CONFIRM ho gaya
      return;
    }
    serverTax = t;
    _rebuildOrderDetail();
  }

  /// Cart page khulte hi (logged-in + saved address ho to) ek silent
  /// preview call se tax fetch — payment page se PEHLE hi row dikh jaye.
  Future<void> fetchServerTax() async {
    if (_taxFetching) return;
    if (cartModelList == null) return;
    if ((storage.read(Session.isLogin) ?? false) != true) return;
    final rawUid = storage.read('id');
    final uid = rawUid is num
        ? rawUid.toInt()
        : (int.tryParse(rawUid?.toString() ?? '') ?? 0);
    if (uid <= 0) return;
    final lines = (cartApiModel?.items ?? const <CartItemModel>[])
        .where((l) => (l.quantity ?? 0) > 0 && (l.productId ?? 0) > 0)
        .map((l) => <String, dynamic>{
              'product_id': l.productId ?? 0,
              // CheckOutProducts.variation_id swagger me STRING hai (int
              // bhejne par .NET model-binding 400 kar deta hai — isliye kabhi
              // kabhi preview hi fail ho jata tha aur tax row nahi banti thi)
              'variation_id': (l.variationId ?? 0) > 0
                  ? '${l.variationId}'
                  : '',
              'quantity': l.quantity ?? 1,
            })
        .toList();
    if (lines.isEmpty) return;
    final addrs = AddressStore.load();
    if (addrs.isEmpty) return;
    int addressId = 0;
    final sel = int.tryParse('${storage.read('selected_address_id') ?? ''}') ?? -1;
    for (final a in addrs) {
      if ((a.id ?? 0) > 0 && (addressId == 0 || a.id == sel)) {
        addressId = a.id ?? 0;
        if (a.id == sel) break;
      }
    }
    if (addressId <= 0) return;
    _taxFetching = true;
    try {
      // DEEP walker: response kisi bhi depth par ho (data/data/order/...),
      // total aur tax DONO nikaal lo. tax keys: name me 'tax' ho (tax,
      // Tax, tax_total, Tax_Total, tax_amount ...) par tax_id NAHI.
      // total keys: total/Total/grand_total/payable/amount_payable — pehla
      // (sabse upar wala) candidate valid. Depth 8, Map+List dono.
      double? deepTotal;
      double? deepTax;
      bool taxKeyOk(String k) {
        final l = k.toLowerCase();
        return l.contains('tax') &&
            !l.contains('tax_id') &&
            !l.contains('taxid') &&
            !l.contains('taxable');
      }

      bool totalKeyOk(String k) {
        final l = k.toLowerCase();
        return l == 'total' ||
            l == 'grand_total' ||
            l == 'payable' ||
            l == 'amount_payable' ||
            l == 'order_total' ||
            l == 'final_total';
      }

      void walk(dynamic node, int depth) {
        if (depth > 8 || node == null) return;
        if (deepTax != null && deepTotal != null) return;
        if (node is Map) {
          node.forEach((k, v) {
            final key = k.toString();
            if (deepTax == null && taxKeyOk(key)) {
              final n = jsonToDouble(v);
              if (n != null && n > 0) deepTax = n;
            }
            if (deepTotal == null && totalKeyOk(key)) {
              final n = jsonToDouble(v);
              if (n != null && n > 0) deepTotal = n;
            }
          });
          if (deepTax == null || deepTotal == null) {
            for (final v in node.values) {
              if (v is Map || v is List) walk(v, depth + 1);
              if (deepTax != null && deepTotal != null) return;
            }
          }
        } else if (node is List) {
          for (final v in node) {
            walk(v, depth + 1);
            if (deepTax != null && deepTotal != null) return;
          }
        }
      }

      final res = await ApiService().request<Map<String, double>?>(
        endpoint: ApiEndpoints.checkout,
        method: ApiMethod.post,
        data: <String, dynamic>{
          'consumer_id': uid,
          'products': lines,
          'shipping_address_id': addressId,
          'billing_address_id': addressId,
          'points_amount': false,
          'wallet_balance': false,
          'delivery_description': '',
          'delivery_interval': '',
          'payment_method': 'cod',
        },
        fromJson: (json) {
          deepTotal = null;
          deepTax = null;
          walk(json, 0);
          final out = <String, double>{};
          if (deepTax != null && deepTax! > 0) out['tax'] = deepTax!;
          if (deepTotal != null && deepTotal! > 0) out['total'] = deepTotal!;
          return out.isEmpty ? null : out;
        },
      );
      if (res.isSuccess && res.data != null) {
        final t = res.data!['tax'] ?? 0;
        final tot = res.data!['total'] ?? 0;
        if (t > 0) {
          // explicit tax mil gaya — authoritative
          applyServerTotals(tot, t);
        } else if (tot > 0) {
          // fallback: server total - bag total = server add-on (tax)
          applyServerTotals(tot, null);
        }
        // Preview me tax nahi (tot ≈ bag) to client-computed tax hi rahega.
      }
    } catch (_) {} finally {
      _taxFetching = false;
    }
  }

  /// Cart item tap ke liye real product (detail page kholne ke liye).
  ProductApiModel? productFor(int productId) => _lookupKnownProduct(productId);

  /// Item REMOVE — pehle sirf ek demo bottom sheet khulta tha aur item
  /// remove hi nahi hota tha. Ab BULLETPROOF 3-step:
  ///  1) UI/list se TURANT hatao + totals dobara ginho,
  ///  2) server par remove karo — is backend me DeleteCart api HAI HI NAHI
  ///     (swagger verify), remove sirf AddToCart (qty 0) se hota hai. Ek hi
  ///     payload par bharosa karne ke bajaye TEEN shapes try karte hai AUR
  ///     har attempt ke baad GetCart se VERIFY karte hai ki item sach me
  ///     gaya — pehle verify nahi hota tha, isliye server-side fail hone par
  ///     item "again and again" wapas aa jata tha (user complaint),
  ///  3) teeno attempts fail ho jaye to UI ko server ke saath sync karke
  ///     HONEST toast dikhate hai (fake removal ka illusion nahi).
  Future<void> removeFromCart(HomeDealOfTheDayModel item) async {
    final pid = item.id;
    cartModelList?.cartList?.removeWhere((e) => e.id == pid);
    // Tax bhi resync tak reset — hataaye gaye item ka tax na dikhta rahe
    // (getCart verify ke baad dobara compute ho jayega).
    serverTax = null;
    _clientTax = null;
    final remaining = cartModelList?.cartList ?? <HomeDealOfTheDayModel>[];
    if (remaining.isEmpty) {
      cartModelList = null;
      serverTax = null;
      _clientTax = null;
      _bagTotalMrp = 0;
      _bagTotalFinal = 0;
    } else {
      double total = 0;
      for (final e in remaining) {
        total += (e.mrp ?? 0);
      }
      // bag totals update karo aur UNIFIED rebuild — Tax row barkarar
      // rehti hai (pehle remove par tax row gayab ho jati thi, Issue #4).
      _bagTotalFinal = total;
      double mrpTotal = 0;
      for (final e in remaining) {
        mrpTotal += (e.totalPrice ?? e.mrp ?? 0);
      }
      _bagTotalMrp = mrpTotal;
      _rebuildOrderDetail();
    }
    update();
    appCtrl.update();

    // server sync (logged-in ho to)
    if ((storage.read(Session.isLogin) ?? false) != true) return;

    // Remove se pehle ka server snapshot — isi se line id + baaki lines
    // milti hai. cartApiModel stale ho sakta hai, isliye pehle ek baar
    // FRESH GetCart kar lete hai (taaki line ids 100% sahi ho).
    List<CartItemModel> prevLines = const <CartItemModel>[];
    try {
      final fresh = await ApiService().request<CartApiModel>(
        endpoint: ApiEndpoints.getCart,
        method: ApiMethod.get,
        fromJson: (json) => CartApiModel.fromJson(json),
      );
      if (fresh.isSuccess && fresh.data != null) {
        cartApiModel = fresh.data;
        prevLines = fresh.data!.items;
      }
    } catch (_) {}
    if (prevLines.isEmpty) {
      prevLines = List<CartItemModel>.from(
          cartApiModel?.items ?? const <CartItemModel>[]);
    }

    // Target line (jo hatani hai) aur USKA REAL line id
    CartItemModel? target;
    for (final l in prevLines) {
      if ((l.productId ?? -1) == pid) {
        target = l;
        break;
      }
    }
    final int lineId = target?.id ?? 0;
    final int? consumerId = target?.consumerId;

    // Server par item already nahi hai (sirf local ghost tha) -> kuch bhejne
    // ki zaroorat hi nahi; bas fresh state se UI settle kar do.
    if (target == null) {
      try {
        await getCart(silent: true);
      } catch (_) {}
      return;
    }

    // Baaki (remaining) live lines — full-sync attempts me bhejenge
    final remainingLines = prevLines
        .where((l) => (l.productId ?? -1) != pid && (l.quantity ?? 0) > 0)
        .toList();
    double remainTotal = 0;
    for (final l in remainingLines) {
      remainTotal += (l.subTotal ?? 0);
    }

    Map<String, dynamic> deadLine() => {
          "id": lineId,
          "product_id": pid,
          "variation_id": target?.variationId,
          if (consumerId != null) "consumer_id": consumerId,
          "quantity": 0,
          "sub_total": 0,
          "wholesale_price": 0,
        };

    final List<Map<String, dynamic>> aliveLines = [
      for (final l in remainingLines)
        {
          "id": l.id ?? 0,
          "product_id": l.productId,
          "variation_id": l.variationId,
          if (l.consumerId != null) "consumer_id": l.consumerId,
          "quantity": l.quantity ?? 1,
          "sub_total": l.subTotal ?? 0,
          "wholesale_price": l.wholesalePrice ?? 0,
        },
    ];

    // logged-in user ka numeric id (CartDto.created_by_id ke liye)
    int? userId;
    final rawId = storage.read('id');
    if (rawId is num) {
      userId = rawId.toInt();
    } else {
      userId = int.tryParse(rawId?.toString() ?? '');
    }

    // PURE-REPLACE body (dead line BINA) — dhyan do: qty-0 line validation
    // fail karke POORI request reject kara sakti hai, isliye ye PEHLE try.
    final Map<String, dynamic> remainingOnlyBody = {
      "total": remainTotal,
      if (userId != null) "created_by_id": userId,
      "items": aliveLines,
    };

    // FULL cart body = bachi hui lines + target line qty 0.
    final Map<String, dynamic> fullCartBody = {
      "total": remainTotal,
      if (userId != null) "created_by_id": userId,
      "items": [...aliveLines, deadLine()],
    };

    // NEGATIVE-quantity line — agar AddToCart sirf INCREMENT karta hai to
    // -1 add karke qty-1 ki line 0 ho jati hai (classic remove trick).
    Map<String, dynamic> negLine() => {
          "id": lineId,
          "product_id": pid,
          "variation_id": target?.variationId,
          if (consumerId != null) "consumer_id": consumerId,
          "quantity": -1,
          "sub_total": 0,
          "wholesale_price": 0,
        };

    // ================================================================
    // VERIFY-CHAIN (14 stages) — har attempt ke baad GetCart se CONFIRM.
    // UpdateCart/ClearCart = HIDDEN endpoints (404-vs-500 probe se confirm
    // route EXISTS — swagger me nahi dikhte).
    // ================================================================
    // — Group A: UpdateCart, PURE REPLACE (dead-line-free), sabse clean —
    bool removed = await _attemptRemove(
        ApiEndpoints.updateCart, ApiMethod.put, remainingOnlyBody, pid);
    if (!removed) {
      removed = await _attemptRemove(
          ApiEndpoints.updateCart, ApiMethod.post, remainingOnlyBody, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.updateCart, ApiMethod.post,
          {...remainingOnlyBody, "_method": "PUT"}, pid);
    }
    // — Group B: UpdateCart with qty-0 dead line embedded —
    if (!removed) {
      removed = await _attemptRemove(
          ApiEndpoints.updateCart, ApiMethod.put, fullCartBody, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(
          ApiEndpoints.updateCart, ApiMethod.post, fullCartBody, pid);
    }
    // — Group C: Line-targeted UpdateCart shapes —
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.updateCart, ApiMethod.post,
          {"id": lineId, "quantity": 0}, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.updateCart, ApiMethod.put,
          {"quantity": 0}, pid,
          queryParams: {"id": lineId});
    }
    // — Group D: AddToCart as REPLACE (remaining only / +dead line) —
    if (!removed) {
      removed = await _attemptRemove(
          ApiEndpoints.addToCart, ApiMethod.post, remainingOnlyBody, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(
          ApiEndpoints.addToCart, ApiMethod.post, fullCartBody, pid);
    }
    // — Group E: NEGATIVE quantity (increment-style remove) —
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.addToCart, ApiMethod.post,
          {"total": remainTotal, "items": [...aliveLines, negLine()]}, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.addToCart, ApiMethod.post,
          {"total": 0, "items": [negLine()]}, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.addToCart, ApiMethod.post,
          {"total": 0, "items": negLine()}, pid);
    }
    // — Group F: legacy qty-0 single-line shapes —
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.addToCart, ApiMethod.post,
          {"total": 0, "items": [deadLine()]}, pid);
    }
    if (!removed) {
      removed = await _attemptRemove(ApiEndpoints.addToCart, ApiMethod.post,
          {"total": 0, "items": deadLine()}, pid);
    }
    // — Group G: Cart me BAS YEKHI live item hai -> ClearCart hi uska
    // valid remove hai! (hidden endpoint, probe-confirmed EXISTS). Sirf
    // tab chalao jab target ke alawa koi live line na ho — doosre items
    // kabhi touch nahi karte.
    if (!removed && remainingLines.isEmpty) {
      removed = await _attemptRemove(
          ApiEndpoints.clearCart, ApiMethod.post, const <String, dynamic>{}, pid);
    }
    if (!removed && remainingLines.isEmpty) {
      removed = await _attemptRemove(ApiEndpoints.clearCart, ApiMethod.post,
          const <String, dynamic>{"_method": "DELETE"}, pid);
    }

    if (!removed) {
      // Tino fail — UI ko server ke saath HONEST sync karo (item dikhega
      // jaisa server par hai) aur user ko batao, taaki fake success ka
      // illusion na rahe.
      try {
        await getCart(silent: true);
      } catch (_) {}
      socialLoginToast("itemNotRemoved".tr);
    }
  }

  /// Ek remove attempt bhejo (kisi bhi cart endpoint/verb se) + FRESH
  /// GetCart se VERIFY karo ki product (pid) server se sach me hat gaya
  /// (koi bhi live qty wali line nahi). Verify response se local state bhi
  /// refresh ho jati hai.
  Future<bool> _attemptRemove(String endpoint, ApiMethod method,
      Map<String, dynamic> body, int pid,
      {Map<String, dynamic>? queryParams}) async {
    try {
      await ApiService().request<CartApiModel>(
        endpoint: endpoint,
        method: method,
        data: body,
        queryParams: queryParams,
        fromJson: (json) => CartApiModel.fromJson(json),
      );
    } catch (_) {}
    try {
      final res = await ApiService().request<CartApiModel>(
        endpoint: ApiEndpoints.getCart,
        method: ApiMethod.get,
        fromJson: (json) => CartApiModel.fromJson(json),
      );
      if (res.isSuccess && res.data != null) {
        // fresh server state local me rakho — next attempt/verify isi par
        cartApiModel = res.data;
        final stillThere = res.data!.items.any(
            (l) => (l.productId ?? -1) == pid && (l.quantity ?? 0) > 0);
        if (!stillThere) {
          cartModelList = _mapApiCartToViewModel(res.data!);
          // VERIFIED remove ke baad cart sach me khaali ho gaya ho to
          // snapshot CLEAR karo — warna placeOrder ghost-items se rescue
          // kar lega. (Khaali nahi hai to getCart/persist baaki items ka
          // naya snapshot bana degi.)
          final anyLive = res.data!.items
              .any((l) => (l.quantity ?? 0) > 0 && (l.productId ?? 0) > 0);
          if (!anyLive) {
            await CartController.clearCartSnapshot();
          }
          update();
          appCtrl.update();
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  /// chhota helper - taaki SocialLoginController import na karna pade sirf toast ke liye
  socialLoginToast(String message) {
    if (message.isEmpty) return;
    snackBar(message, context: Get.context);
  }

  //common bottom sheet
  bottomSheetLayout(text) {
    Get.bottomSheet(
      CommonBottomSheet(text:text),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }
}
