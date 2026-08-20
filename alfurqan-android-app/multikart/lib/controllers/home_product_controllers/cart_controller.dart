import 'package:multikart/models/cart_api_model.dart';
import 'package:multikart/services/api_endpoints.dart';
import 'package:multikart/services/api_service.dart';

import '../../config.dart';

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
    similarList = AppArray().similarProductList;
    appCtrl.isShimmer = true;
    appCtrl.update();
    update();
    getCart();
    super.onReady();
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

    final res = await ApiService().request<CartApiModel>(
      endpoint: ApiEndpoints.addToCart,
      method: ApiMethod.post,
      data: {
        "total": subTotal,
        "items": {
          "id": 0,
          "product_id": productId,
          "variation_id": variationId,
          "quantity": quantity,
          "sub_total": subTotal,
          "wholesale_price": wholesalePrice,
        }
      },
      fromJson: (json) => CartApiModel.fromJson(json),
    );

    isCartLoading = false;

    if (res.isSuccess && res.data != null) {
      // response me jo pura cart aaya, wahi local me save/update kar liya
      cartApiModel = res.data;
      cartModelList = _mapApiCartToViewModel(res.data!);
      socialLoginToast(res.message);
      update();
      return true;
    } else {
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
      final product = item.product;
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
          id: item.id ?? item.productId ?? 0,
          name: product?.name ?? 'Product #${item.productId ?? ''}',
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
