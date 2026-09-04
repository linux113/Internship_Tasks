import '../../config.dart';
import '../../models/cart_api_model.dart';
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

  /// Issue#3 fix ke liye: Order success page ko REAL order dikhani hai
  /// (pehle STATIC fashion cloths ka fake summary dikhta tha!). Order
  /// place hote hi yaha snapshot banta hai — offAllNamed ke baad bhi
  /// static field survive karti hai (payment controller delete ho jata hai).
  static Map<String, dynamic>? lastPlacedOrder;

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
  /// PRIMARY source = cartApiModel.items (REAL product_id + REAL quantity —
  /// seedha GetCart response se). Pehle sirf view-model ("Qty: N" text ko
  /// regex se parse karke) banta tha — agar server line me product_id na
  /// ho to galat LINE-ID product_id ban jaati thi aur order fail/wrong
  /// product ho sakta tha. View-model ab sirf FALLBACK hai.
  List<Map<String, dynamic>> _orderProducts() {
    final c = _cartCtrl;
    if (c == null) return [];
    final items = <Map<String, dynamic>>[];

    // PRIMARY: api cart lines
    for (final l in (c.cartApiModel?.items ?? const <CartItemModel>[])) {
      final pid = l.productId ?? 0;
      final qty = l.quantity ?? 0;
      if (pid > 0 && qty > 0) {
        items.add({
          'product_id': pid,
          'variation_id': l.variationId,
          'quantity': qty,
        });
      }
    }
    if (items.isNotEmpty) return items;

    // FALLBACK: view-model (puraana tarika)
    for (final e in (c.cartModelList?.cartList ?? [])) {
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

  /// Selected delivery address ka formatted text — success page par
  /// "This order will be shipped to:" ke neeche REAL address dikhane ke
  /// liye (pehle STATIC New York ka fake address aata tha!).
  String _selectedAddressText() {
    try {
      final list = AddressStore.load();
      final selRaw = storage.read('selected_address_id');
      final sel = int.tryParse(selRaw?.toString() ?? '') ?? -1;
      AddressModel? found;
      for (final a in list) {
        if (a.id == sel) {
          found = a;
          break;
        }
      }
      found ??= list.isNotEmpty ? list.first : null;
      if (found == null) return '';
      final parts = <String>[
        if ((found.fullName ?? '').trim().isNotEmpty) found.fullName!.trim(),
        if ((found.street ?? '').trim().isNotEmpty) found.street!.trim(),
        if ((found.landmark ?? '').trim().isNotEmpty) found.landmark!.trim(),
        if ((found.city ?? '').trim().isNotEmpty) found.city!.trim(),
        if ((found.pincode ?? '').trim().isNotEmpty) found.pincode!.trim(),
      ];
      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  /// Order success ke baad SERVER ka cart bhi saaf karo (probe-confirmed
  /// hidden endpoint Cart/ClearCart) + GetCart se settle. Best-effort:
  /// fail ho to kuch nahi toot-ta (next GetCart state le aayega).
  Future<void> _clearServerCart() async {
    try {
      await ApiService().request(
        endpoint: ApiEndpoints.clearCart,
        method: ApiMethod.post,
        data: const <String, dynamic>{},
        fromJson: (json) => json,
      );
    } catch (_) {}
  }

  /// MAIN ACTION — "Place Order" button yahi call karta hai.
  Future<void> placeOrder() async {
    if (isPlacing) return;

    // 1) login zaroori
    if (!isLoggedIn) {
      _toast('pleaseLoginFirst'.tr);
      Get.toNamed(routeName.login);
      return;
    }

    // 2) cart khaali nahi honi chahiye — LEKIN pehle ek baar server se
    // REFRESH karke dekho: kabhi-kabhi local cart state stale/null ho jati
    // hai jabki server par items MOJOOD hote hai. Aise me galat "cart
    // khaali" toast aa jata tha (user report). Refresh ke baad bhi khaali
    // ho tabhi toast do.
    var products = _orderProducts();
    if (products.isEmpty) {
      try {
        await _cartCtrl?.getCart(silent: true);
      } catch (_) {}
      products = _orderProducts();
    }
    if (products.isEmpty) {
      _toast('cartEmptyToast'.tr);
      Get.offAllNamed(routeName.dashboard);
      return;
    }

    // 3) server address chahiye
    final addressId = _serverAddressId();
    if (addressId <= 0) {
      _toast('saveDeliveryAddressFirst'.tr);
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
      // FIX: khaali coupon string bhejne par kuch backends 400 reject karte
      // hai — coupon ho tabhi key bhejo.
      if (coupon.isNotEmpty) 'coupon': coupon,
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
        // ---- Issue#3: success page ke liye REAL order snapshot banao ----
        // cart clear hone se PEHLE items ka naam/qty/price pakad lo.
        final snapItems = <Map<String, dynamic>>[];
        final c0 = _cartCtrl;
        for (final e in (c0?.cartModelList?.cartList ?? [])) {
          final m = RegExp(r'(\d+)').firstMatch(e.byWhom ?? '');
          final qty = m != null ? (int.tryParse(m.group(1)!) ?? 1) : 1;
          snapItems.add({
            'name': e.name ?? '',
            'image': e.image ?? '',
            'qty': qty,
            'price': e.mrp ?? 0,
          });
        }
        // response se order id — shape lenient (id / order_id / data.id...)
        int orderId = 0;
        try {
          dynamic d = res.data;
          for (var i = 0; i < 3 && d is Map; i++) {
            final v = d['id'] ?? d['Id'] ?? d['order_id'] ?? d['Order_Id'];
            if (v != null) {
              orderId = int.tryParse(v.toString()) ?? 0;
              break;
            }
            d = d['data'] ?? d['Data'] ?? d['order'] ?? d['Order'];
          }
        } catch (_) {}
        lastPlacedOrder = {
          'items': snapItems,
          'total': _currentTotal(),
          'orderId': orderId,
          'payment': paymentMethod == 'cod' ? 'Cash on Delivery' : paymentMethod,
          // REAL delivery address (success page STATIC New York ke bajaye)
          'address': _selectedAddressText(),
        };

        // local cart saaf + coupon reset
        final c = _cartCtrl;
        if (c != null) {
          c.cartModelList = null;
          c.cartApiModel = null;
          c.update();
        }
        await storage.write('coupon_code', '');
        // SERVER cart bhi saaf karo — warna agle app-open par purane items
        // GetCart se WAPAS aa jate (order place hone ke baad cart ka
        // sach me khali hona chahiye).
        await _clearServerCart();
        try {
          await _cartCtrl?.getCart(silent: true);
        } catch (_) {}
        // FIX: navigation ke BAAD update() mat karo — offAll se ye page pop
        // hota hai aur controller delete ho sakta hai (update-after-dispose
        // race). Pehle state theek karo, phir navigate karke RETURN.
        isPlacing = false;
        update();
        _toast(res.message.isNotEmpty
            ? res.message
            : 'orderPlacedSuccess'.tr);
        Get.offAllNamed(routeName.orderSuccess, arguments: totalText);
        return;
      } else {
        _toast(res.message.isNotEmpty
            ? res.message
            : 'orderFailedTryAgain'.tr);
      }
    } catch (_) {
      _toast('orderFailedTryAgain'.tr);
    }

    isPlacing = false;
    update();
  }
}
