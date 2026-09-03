import 'package:multikart/models/cart_api_model.dart';
import 'package:multikart/models/product_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

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
  /// Return = true agar api ne success diya, warna false.
  Future<bool> addToCart({
    required int productId,
    int? variationId,
    required int quantity,
    required double subTotal,
    double wholesalePrice = 0,
  }) async {
    isCartLoading = true;
    update();

    final Map<String, dynamic> itemBody = {
      "id": 0,
      "product_id": productId,
      "variation_id": variationId,
      "quantity": quantity,
      "sub_total": subTotal,
      "wholesale_price": wholesalePrice,
    };

    // Swagger ke CartDto schema ke mutabik `items` ek ARRAY honi chahiye —
    // pehle wahi bhejo. Kuch backend builds single OBJECT bhi accept karti
    // hai, isliye fail hone par object shape ek baar fallback retry karo.
    var res = await ApiService().request<CartApiModel>(
      endpoint: ApiEndpoints.addToCart,
      method: ApiMethod.post,
      data: {
        "total": subTotal,
        "items": [itemBody],
      },
      fromJson: (json) => CartApiModel.fromJson(json),
    );

    if (!res.isSuccess && res.code != 401) {
      res = await ApiService().request<CartApiModel>(
        endpoint: ApiEndpoints.addToCart,
        method: ApiMethod.post,
        data: {
          "total": subTotal,
          "items": itemBody,
        },
        fromJson: (json) => CartApiModel.fromJson(json),
      );
    }

    isCartLoading = false;

    if (res.isSuccess && res.data != null) {
      // response me jo pura cart aaya, wahi local me save/update kar liya
      cartApiModel = res.data;
      cartModelList = _mapApiCartToViewModel(res.data!);
      socialLoginToast(res.message);
      update();
      return true;
    } else {
      // Backend cart ke liye login mangta hai — 401 aaye to sirf toast ke
      // bajaye seedha login page pe le jao (warna user ko samajh nahi aata
      // ki Add to Cart kyu nahi ho raha).
      if (res.code == 401) {
        socialLoginToast(res.message.isNotEmpty
            ? res.message
            : 'Please login to add items to your cart.');
        update();
        Get.toNamed(routeName.login);
        return false;
      }
      socialLoginToast(res.message);
      update();
      return false;
    }
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

  /// Real api cart (CartApiModel) ko app ke existing cart UI ke model
  /// (CartModel) me convert karna — isse cart screen ka koi bhi widget
  /// change kiye bina real api ka data dikhne lagta hai.
  /// Agar cart khaali ho to null return hota hai (EmptyCart dikhega).
  CartModel? _mapApiCartToViewModel(CartApiModel apiCart) {
    if (apiCart.items.isEmpty) return null;

    final List<HomeDealOfTheDayModel> viewItems = [];
    double bagTotalMrp = 0; // original (mrp) prices ka sum
    double bagTotalFinal = 0; // selling prices ka sum

    for (final item in apiCart.items) {
      // GHOST-FIX: backend Remove (quantity 0) karne ke baad bhi GetCart me
      // wahi line quantity 0 ke saath bhejta rehta hai. Pehle hum use
      // dabakar wapas "Qty: 1" bana dete the — isliye wahi kitaab hamesha
      // wapas dikhti thi. Ab zero-quantity line list me hi NAHI aayegi.
      if ((item.quantity ?? 0) <= 0) continue;
      ProductApiModel? product = item.product;
      if ((product == null || (product.name ?? '').isEmpty) &&
          item.productId != null) {
        final found = _lookupKnownProduct(item.productId!);
        if (found != null) product = found;
      }
      final int qty = item.quantity!; // upar qty<=0 lines skip ho chuki hain

      // per-unit price: pehle product detail se, warna line subTotal se nikaalo
      double unitMrp = product?.price ?? 0;
      double unitFinal = product?.finalPrice ?? 0;
      if (unitFinal <= 0 && (item.subTotal ?? 0) > 0) {
        unitFinal = item.subTotal! / qty;
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
    final double savings = bagTotalMrp - bagTotalFinal;

    // EDGE-FIX: saari lines zero-qty nikli (ya koi valid item nahi bana) to
    // EMPTY cart dikhao — warna khali CartModel se "blank" screen aati thi.
    if (viewItems.isEmpty) return null;

    return CartModel(
      cartList: viewItems,
      totalAmount: total,
      orderDetail: [
        OrderDetail(title: "Bag total".tr, value: bagTotalMrp),
        if (savings > 0) OrderDetail(title: "Bag savings".tr, value: savings),
        OrderDetail(title: "Coupon Discount".tr, value: "Apply Coupon".tr),
        OrderDetail(title: "Delivery".tr, value: 0.0),
      ],
      deliveryChargesInstruction: _demoDeliveryCharges,
      deliveryInstruction: _demoDeliveryInstruction,
    );
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
    final remaining = cartModelList?.cartList ?? <HomeDealOfTheDayModel>[];
    if (remaining.isEmpty) {
      cartModelList = null;
    } else {
      double total = 0;
      for (final e in remaining) {
        total += (e.mrp ?? 0);
      }
      cartModelList!.totalAmount = total;
      // order detail bhi turant refresh karo (Bag total/Savings)
      double mrpTotal = 0;
      for (final e in remaining) {
        mrpTotal += (e.totalPrice ?? e.mrp ?? 0);
      }
      cartModelList!.orderDetail = [
        OrderDetail(title: "Bag total".tr, value: mrpTotal),
        if (mrpTotal - total > 0)
          OrderDetail(title: "Bag savings".tr, value: mrpTotal - total),
        OrderDetail(title: "Coupon Discount".tr, value: "Apply Coupon".tr),
        OrderDetail(title: "Delivery".tr, value: 0.0),
      ];
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
