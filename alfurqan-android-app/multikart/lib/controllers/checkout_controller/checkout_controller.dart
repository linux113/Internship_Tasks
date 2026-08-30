import '../../config.dart';
import '../../models/location_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../utilities/address_store.dart';
import '../home_product_controllers/cart_controller.dart';

/// CHECKOUT / PLACE ORDER — sabse bada feature.
/// Pehle payment page ka "Pay Now" seedha STATIC success screen par chala
/// jata tha — server par order kabhi POST hi nahi hota tha!
///
/// Ab REAL flow (swagger se verify):
///   1) POST api/Orders/CheckOut  (CheckOutPayloadDto — preview, best-effort)
///   2) POST api/Orders/OrderPlace (OrderSaveDto — FINAL order)
/// Body: {consumer_id, products:[{product_id, variation_id, quantity}],
///        shipping_address_id, billing_address_id, points_amount,
///        wallet_balance, coupon, delivery_description, delivery_interval,
///        payment_method}
class CheckoutController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  bool isPlacing = false;
  String paymentMethod = 'cod'; // default: Cash on Delivery
  final TextEditingController txtCoupon = TextEditingController();

  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  int get _userId {
    final raw = storage.read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  void _toast(String msg) {
    final c = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    c.showToast(msg);
  }

  /// Cart page ka controller — cart → delivery → payment sab PUSH hote hai,
  /// isliye CartController abhi zinda hoga (Get.find use kar sakte hai).
  CartController? get _cartCtrl =>
      Get.isRegistered<CartController>() ? Get.find<CartController>() : null;

  /// Server ko bhejne wala products list.
  List<Map<String, dynamic>> _orderProducts() {
    final c = _cartCtrl;
    if (c == null) return [];
    final items = <Map<String, dynamic>>[];
    for (final e in (c.cartModelList?.cartList ?? [])) {
      // view-model me quantity byWhom="Qty: N" me hoti hai — wapas nikaalo
      int qty = 1;
      final m = RegExp(r'(\d+)').firstMatch(e.byWhom ?? '');
      if (m != null) qty = int.tryParse(m.group(1)!) ?? 1;
      if (e.id > 0) {
        items.add({
          'product_id': e.id,
          'variation_id': null,
          'quantity': qty <= 0 ? 1 : qty,
        });
      }
    }
    return items;
  }

  /// Selected (ya default) SERVER address ka id. Address sirf tab kaam
  /// aayega jab wo server par saved ho (Location/AddAddress se) — sirf
  /// local id bhejne par FK error aayegi.
  int _serverAddressId() {
    final list = AddressStore.load();
    final selRaw = storage.read('selected_address_id');
    final sel = int.tryParse(selRaw?.toString() ?? '') ?? -1;
    if (sel > 0) {
      for (final a in list) {
        if (a.id == sel && a.fromServer) return a.id ?? -1;
      }
    }
    // fallback: koi bhi SERVER-saved address
    for (final a in list) {
      if (a.fromServer) return a.id ?? -1;
    }
    return -1;
  }

  String _currentTotal() {
    final c = _cartCtrl;
    final t = c?.cartModelList?.totalAmount;
    return t == null ? '0' : t.toString();
  }

  /// MAIN ACTION — "Place Order" button yahi call karta hai.
  Future<void> placeOrder() async {
    if (isPlacing) return;

    // 1) login zaroori
    if (!isLoggedIn) {
      _toast('Please login first');
      Get.toNamed(routeName.login);
      return;
    }

    // 2) cart khaali nahi honi chahiye
    final products = _orderProducts();
    if (products.isEmpty) {
      _toast('Aapki cart khaali hai');
      Get.offAllNamed(routeName.dashboard);
      return;
    }

    // 3) server address chahiye
    final addressId = _serverAddressId();
    if (addressId <= 0) {
      _toast('Pehle delivery address save karein');
      Get.toNamed(routeName.addAddress);
      return;
    }

    final totalText = _currentTotal();
    // coupon: payment page box ya coupons page se selected code
    String coupon = txtCoupon.text.trim();
    if (coupon.isEmpty) {
      coupon = storage.read('coupon_code')?.toString() ?? '';
    }

    isPlacing = true;
    update();

    final payload = <String, dynamic>{
      'consumer_id': _userId,
      'products': products,
      'shipping_address_id': addressId,
      'billing_address_id': addressId,
      'points_amount': false,
      'wallet_balance': false,
      'coupon': coupon,
      'delivery_description': '',
      'delivery_interval': '',
      'payment_method': paymentMethod,
    };

    try {
      // STEP 1 — CheckOut preview (best-effort; fail ho to bhi aage badho —
      // kuch backends OrderPlace khud totals validate karta hai)
      try {
        await ApiService().request(
          endpoint: ApiEndpoints.checkout,
          method: ApiMethod.post,
          data: payload,
          fromJson: (json) => json,
        );
      } catch (_) {}

      // STEP 2 — FINAL: order place
      final res = await ApiService().request(
        endpoint: ApiEndpoints.placeOrder,
        method: ApiMethod.post,
        data: payload,
        fromJson: (json) => json,
      );

      if (res.isSuccess) {
        // local cart saaf + coupon reset
        final c = _cartCtrl;
        if (c != null) {
          c.cartModelList = null;
          c.cartApiModel = null;
          c.update();
        }
        await storage.write('coupon_code', '');
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Order placed successfully!');
        Get.offAllNamed(routeName.orderSuccess, arguments: totalText);
      } else {
        _toast(res.message.isNotEmpty
            ? res.message
            : 'Order place nahi ho paya — dobara try karein');
      }
    } catch (_) {
      _toast('Order place nahi ho paya — internet/servers check karke dobara try karein');
    }

    isPlacing = false;
    update();
  }
}
