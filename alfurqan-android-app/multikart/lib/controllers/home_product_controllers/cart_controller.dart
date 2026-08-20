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
    // TODO: implement onReady
    cartModelList = cartList;
    similarList = AppArray().similarProductList;
    update();
    getCart();
    super.onReady();
  }

  /// Cart me product add karna (Cart/AddToCart)
  /// [wholesalePrice] optional - na ho to 0 bhej dena.
  addToCart({
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
      socialLoginToast(res.message);
    } else {
      socialLoginToast(res.message);
    }

    update();
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

    if (res.isSuccess && res.data != null) {
      cartApiModel = res.data;
    }

    update();
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
