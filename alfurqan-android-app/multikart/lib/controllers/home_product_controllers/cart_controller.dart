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

    // Pehle doc ke mutabik `items` OBJECT bhejo. Backend agar `items` ko
    // ARRAY maange to validation error (400) deta hai — us case me array
    // shape ke sath ek baar phir try karo. Dono shapes cover ho gaye.
    var res = await ApiService().request<CartApiModel>(
      endpoint: ApiEndpoints.addToCart,
      method: ApiMethod.post,
      data: {
        "total": subTotal,
        "items": itemBody,
      },
      fromJson: (json) => CartApiModel.fromJson(json),
    );

    if (!res.isSuccess && res.code == 400) {
      res = await ApiService().request<CartApiModel>(
        endpoint: ApiEndpoints.addToCart,
        method: ApiMethod.post,
        data: {
          "total": subTotal,
          "items": [itemBody],
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
  getCart() async {
    isCartLoading = true;
    update();

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
      // GetCart kabhi-kabhi product detail (name/image/price) NAHI bhejta.
      // Us case me app ke paas pehle se loaded product pools (home api +
      // newest) se id match karke detail bharo — warna "Product #264" jaisa
      // naam aur khali image dikhti thi.
      ProductApiModel? product = item.product;
      if ((product == null || (product.name ?? '').isEmpty) &&
          item.productId != null) {
        final found = _lookupKnownProduct(item.productId!);
        if (found != null) product = found;
      }
      final int qty = (item.quantity ?? 1) <= 0 ? 1 : (item.quantity ?? 1);

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
  /// remove hi nahi hota tha. Ab:
  ///  1) UI/list se TURANT hatao + totals dobara ginho,
  ///  2) server par quantity 0 wala AddToCart bhejo (is backend me alag
  ///     DeleteCart api nahi hai — qty 0 se item replace/remove hota hai),
  ///  3) GetCart se fresh state la kar confirm karo.
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
    if ((storage.read(Session.isLogin) ?? false) == true) {
      try {
        final Map<String, dynamic> itemBody = {
          "id": 0,
          "product_id": pid,
          "variation_id": null,
          "quantity": 0,
          "sub_total": 0,
          "wholesale_price": 0,
        };
        var res = await ApiService().request<CartApiModel>(
          endpoint: ApiEndpoints.addToCart,
          method: ApiMethod.post,
          data: {"total": 0, "items": itemBody},
          fromJson: (json) => CartApiModel.fromJson(json),
        );
        if (!res.isSuccess && res.code == 400) {
          res = await ApiService().request<CartApiModel>(
            endpoint: ApiEndpoints.addToCart,
            method: ApiMethod.post,
            data: {"total": 0, "items": [itemBody]},
            fromJson: (json) => CartApiModel.fromJson(json),
          );
        }
      } catch (_) {}
      // fresh server state se list final confirm karo
      try {
        await getCart();
      } catch (_) {}
    }
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
