import '../../config.dart';
import '../../models/cart_api_model.dart';
import '../../models/json_parse_utils.dart';
import '../../models/location_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../services/tax_service.dart';
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

  /// Orders/CheckOut ka server-computed grand total (RAW AED) — payment
  /// page ka bottom bar isko sabse UPAR prefer karta hai (backend 06/09:
  /// "Orders/CheckOut — use this api for check out"). null = preview na mila.
  double? serverPreviewTotal;

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
          // Swagger (10/09): CheckOutProducts.variation_id STRING hai.
          // int bhejne par .NET model-binding 400 de sakta hai — isi liye
          // CheckOut preview kabhi-kabhi fail hota tha (aur payment page
          // par tax/total nahi aata tha).
          'variation_id':
              (l.variationId ?? 0) > 0 ? '${l.variationId}' : '',
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
          'variation_id': '',
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

  /// Payment screen khulne par Orders/CheckOut se server-computed grand
  /// total laao (shipping/tax/coupon sab samet — OrderSaveDto/CheckOut
  /// PayloadDto dono same shape ke hai, swagger se verify). Best-effort:
  /// guest/khaali-cart/no-address/api-fail par serverPreviewTotal null hi
  /// rahega aur UI apna live-cart fallback dikhta rahega.
  Future<void> loadCheckoutPreview() async {
    serverPreviewTotal = null;
    if (!isLoggedIn) return;
    // Tax rates bhi refresh karo (payment page ka deterministic tax row
    // preview fail hone par bhi sahi rahe — order #1078 math se verified).
    try {
      TaxService.load();
    } catch (_) {}
    try {
      var products = _orderProducts();
      if (products.isEmpty) {
        try {
          await _cartCtrl?.getCart(silent: true);
        } catch (_) {}
        products = _orderProducts();
      }
      if (products.isEmpty) {
        // storage snapshot rescue (GetCart flake — preview total bhi sahi
        // aana chahiye, NA ki 0/dikh hi na).
        final snap = CartController.readCartSnapshot(_userId);
        if (snap != null) {
          products = List<Map<String, dynamic>>.from(snap['products'] as List);
        }
      }
      if (products.isEmpty) return;
      final addressId = _serverAddressId();
      if (addressId <= 0) return;
      var coupon = txtCoupon.text.trim();
      if (coupon.isEmpty) {
        coupon = storage.read('coupon_code')?.toString() ?? '';
      }
      final res = await ApiService().request<Map<String, double>?>(
        endpoint: ApiEndpoints.checkout,
        method: ApiMethod.post,
        data: <String, dynamic>{
          'consumer_id': _userId,
          'products': products,
          'shipping_address_id': addressId,
          'billing_address_id': addressId,
          'points_amount': false,
          'wallet_balance': false,
          if (coupon.isNotEmpty) 'coupon': coupon,
          'delivery_description': '',
          'delivery_interval': '',
          'payment_method': paymentMethod,
        },
        fromJson: (json) {
          // DEEP walker (10/09 deep-fix): total ke SAATH explicit tax bhi
          // dhundo — response kisi bhi depth/shape par ho (data/Data/
          // order/Data.data ...). tax keys: 'tax' samet sab (tax_total,
          // Tax_Total, tax_amount...), tax_id NAHI. Pehle sirf 4-level
          // unwrap + 4 fixed keys the — shape tb preview se tax row
          // kabhi nahi banti thi.
          double? deepTotal;
          double? deepTax;
          void walk(dynamic node, int depth) {
            if (depth > 8 || node == null) return;
            if (deepTax != null && deepTotal != null) return;
            if (node is Map) {
              node.forEach((k, v) {
                final key = k.toString().toLowerCase();
                if (deepTax == null &&
                    key.contains('tax') &&
                    !key.contains('tax_id') &&
                    !key.contains('taxid') &&
                    !key.contains('taxable')) {
                  final n = jsonToDouble(v);
                  if (n != null && n > 0) deepTax = n;
                }
                if (deepTotal == null &&
                    (key == 'total' ||
                        key == 'grand_total' ||
                        key == 'payable' ||
                        key == 'amount_payable' ||
                        key == 'order_total' ||
                        key == 'final_total')) {
                  final n = jsonToDouble(v);
                  if (n != null && n > 0) deepTotal = n;
                }
              });
              for (final v in node.values) {
                if (v is Map || v is List) walk(v, depth + 1);
                if (deepTax != null && deepTotal != null) return;
              }
            } else if (node is List) {
              for (final v in node) {
                walk(v, depth + 1);
                if (deepTax != null && deepTotal != null) return;
              }
            }
          }

          walk(json, 0);
          final out = <String, double>{};
          if (deepTax != null && deepTax! > 0) out['tax'] = deepTax!;
          if (deepTotal != null && deepTotal! > 0) out['total'] = deepTotal!;
          return out.isEmpty ? null : out;
        },
      );
      if (res.isSuccess && res.data != null) {
        serverPreviewTotal = res.data!['total'];
        // Issue #4 (10/09 REVISITED): payment page ka totals
        // (CartOrderDetailLayout) CartController ke model se banta hai —
        // preview ke total + explicit tax se TAX row waha bhi dikhao
        // (order place hone ke BAAD detail me jo tax dikhta hai, wahi ab
        // PEHLE payment/cart me — server value authoritative).
        try {
          final t = res.data!['tax'];
          final tot = res.data!['total'] ?? 0;
          if ((t ?? 0) > 0 || tot > 0) {
            _cartCtrl?.applyServerTotals(tot, (t ?? 0) > 0 ? t : null);
          }
        } catch (_) {}
        update();
      }
    } catch (_) {}
  }

  /// MAIN ACTION — "Place Order" button yahi call karta hai.
  /// GetUserOrders ke RAW rows laao (naya-order identify karne ke liye —
  /// snapshot/POLL dono isi se). paginate=100 — sab rows ek hi call me.
  Future<List<Map<String, dynamic>>> _fetchOrderRows() async {
    try {
      final r = await ApiService().request<List<Map<String, dynamic>>>(
        endpoint: ApiEndpoints.getUserOrders,
        method: ApiMethod.get,
        queryParams: const {'page': '1', 'paginate': '100'},
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ??
                raw['Data'] ??
                raw['orders'] ??
                raw['Orders'] ??
                raw['items'];
          }
          if (raw is! List) return <Map<String, dynamic>>[];
          return raw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        },
      );
      if (r.isSuccess && r.data != null) return r.data!;
    } catch (_) {}
    return const [];
  }

  /// Row ka STABLE PK (id) — ye unique hota hai; order_number server baad
  /// me assign karta hai isliye snapshot identity PK hi hai.
  static int _rowPk(Map<String, dynamic> m) =>
      int.tryParse((m['id'] ??
                  m['Id'] ??
                  m['order_id'] ??
                  m['Order_Id'] ??
                  m['orderId'] ??
                  m['OrderId'])
              ?.toString() ??
          '') ??
      0;

  /// Row ka order_number (display number) — na ho to 0.
  static int _rowOrderNumber(Map<String, dynamic> m) =>
      int.tryParse((m['order_number'] ??
                  m['Order_Number'] ??
                  m['orderNumber'] ??
                  m['order_no'])
              ?.toString() ??
          '') ??
      0;

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
    // ⭐ VISIBLE-TRUTH SNAPSHOT (06/09 3:08pm LIVE glitch — payment page
    // par AED 65/95 total dikh raha tha phir bhi "Your cart is empty"!):
    // ROOT: server ka GetCart kabhi-kabhi galti se EMPTY deta hai (FLAKY
    // — pichli versions me bhi isi liye double-verify banai thi). 1-2
    // refreshes bhi dono empty aaye, par user ko to JITNE bhi items cart/
    // payment page par DIKH rahe the wo sach hai. Orders/CheckOut +
    // OrderPlace dono products[] hamare payload se lete hai — server cart
    // se farak NAHI padta. Isliye refresh se PEHLE jo user ko dikh raha
    // tha wo snapshot rakho; refreshes empty aaye to wahi use karo.
    final preRefreshProducts = products;
    var preRefreshTotal = _currentTotal();
    final cPre = _cartCtrl;
    final preSnapItems = <Map<String, dynamic>>[
      for (final e in (cPre?.cartModelList?.cartList ?? []))
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
    ];
    // FALSE-EMPTY guard: ek transient network hiccup par refresh shuru me
    // khaali de sakta hai — 2 baar refresh karke tabhi empty maano.
    for (var attempt = 0; attempt < 2 && products.isEmpty; attempt++) {
      try {
        await _cartCtrl?.getCart(silent: true);
      } catch (_) {}
      products = _orderProducts();
      if (products.isEmpty && attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 700));
      }
    }
    if (products.isEmpty) {
      if (preRefreshProducts.isNotEmpty) {
        // server ka empty JHOOTH nikla (user items dekh raha tha) —
        // visible items se hi order banao. Galat "cart khaali" toast +
        // user ka dobara-do combo tap karna — bilkul khatam.
        products = preRefreshProducts;
      } else {
        // ⭐ PERSISTENT snapshot rescue (06/09 4pm — "pehli baar payment
        // par empty, back karke aao to chalta hai"): payment-entry ke
        // silent GetCart FLAKE ne in-memory models PEHLE HI null kar
        // diye the — placeOrder tak memory me kuch bacha hi nahi. Ab
        // last VERIFIED non-empty cart (storage, same user, <30min,
        // intentionally-clear nahi) se order banao. Orders CheckOut/
        // OrderPlace products[] payload se chalte hai — server cart ka
        // is-moment-empty hona irrelevant hai.
        final snap = CartController.readCartSnapshot(_userId);
        if (snap != null) {
          products = List<Map<String, dynamic>>.from(snap['products'] as List);
          if (preRefreshTotal == '0') {
            preRefreshTotal = (snap['total'] ?? '0').toString();
          }
          if (preSnapItems.isEmpty) {
            preSnapItems
                .addAll(List<Map<String, dynamic>>.from(snap['items'] as List));
          }
        } else {
          _toast('cartEmptyToast'.tr);
          // FIX: galat-empty par dashboard par DHAKA mat do (stack bhi
          // tootta tha) — user yahin rahe aur dobara try kar sake.
          return;
        }
      }
    }

    // 3) server address chahiye
    final addressId = _serverAddressId();
    if (addressId <= 0) {
      _toast('saveDeliveryAddressFirst'.tr);
      Get.toNamed(routeName.addAddress);
      return;
    }

    // flaky GetCart ne cartModelList NULL kar diya ho to '0' na bane —
    // refresh se PEHLE user ko jo total dikh raha tha wahi lo.
    final totalText =
        preRefreshTotal != '0' ? preRefreshTotal : _currentTotal();
    // coupon: payment page box ya coupons page se selected code
    String coupon = txtCoupon.text.trim();
    if (coupon.isEmpty) {
      coupon = storage.read('coupon_code')?.toString() ?? '';
    }

    isPlacing = true;
    update();

    // ISSUE-FIX (06/09 — "dono orders ka success-page number SAME #1041
    // aaya"): purana fallback GetUserOrders ke SAB rows me se MAX number
    // uthata tha — server naye order ka order_number TURANT assign nahi
    // karta (rows pehle number ke BINA dikhti hai / baad me number lagta
    // hai), isliye max() PURANE order ka #1041 hi pakad leta tha. Ab
    // place karne se PEHLE existing orders ke PK ka snapshot lete hai aur
    // baad me snapshot ke BAHAR wali NAYI row ko hi mera order maante
    // hai — kisi doosre order ka number kabhi nahi dikh sakta.
    final beforePks = <int>{
      for (final r in await _fetchOrderRows()) _rowPk(r),
    }..remove(0);

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

      // STEP 2 — FINAL: order place.
      // PAYLOAD VARIANT RETRY (06/09 — user ko "Server error (400)" mila):
      // backend ki validation live badal rahi hai — kuch servers NULL
      // variation_id reject karte hai, kuch MISSING key ko, kuch khaali
      // delivery_description ko. 3 shapes try karo; pehla success final.
      final variants = <Map<String, dynamic>>[];
      variants.add(payload); // V1: as-is (aaj tak yahi chalta tha)
      // V2: null/khaali variation_id key HATAO + khaali strings hatao
      final v2 = Map<String, dynamic>.from(payload);
      v2['products'] = [
        for (final p in products)
          <String, dynamic>{
            'product_id': p['product_id'],
            if ((p['variation_id']?.toString() ?? '').isNotEmpty)
              'variation_id': p['variation_id'],
            'quantity': p['quantity'],
          }
      ];
      v2.remove('delivery_description');
      v2.remove('delivery_interval');
      variants.add(v2);
      // V3: variation_id "" (kuch validators ko empty-STRING chahiye)
      final v3 = Map<String, dynamic>.from(v2);
      v3['products'] = [
        for (final p in products)
          <String, dynamic>{
            'product_id': p['product_id'],
            'variation_id': (p['variation_id']?.toString() ?? ''),
            'quantity': p['quantity'],
          }
      ];
      variants.add(v3);

      ApiResponse<dynamic>? lastRes;
      for (final body in variants) {
        lastRes = await ApiService().request(
          endpoint: ApiEndpoints.placeOrder,
          method: ApiMethod.post,
          data: body,
          fromJson: (json) => json,
        );
        if (lastRes.isSuccess) break;
        // sirf validation-400 par agla variant try; 401/network par ruk jao
        if (lastRes.code != null && lastRes.code != 400) break;
      }
      final res = lastRes!;

      if (res.isSuccess) {
        // ---- Issue#3: success page ke liye REAL order snapshot banao ----
        // cart clear hone se PEHLE items ka naam/qty/price pakad lo.
        var snapItems = <Map<String, dynamic>>[];
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
        // flaky GetCart ne guard ke dauraan cartModelList khaali kar diya
        // ho to success page KHAALI summary na dikhe — visible snapshot.
        if (snapItems.isEmpty) snapItems = preSnapItems;
        // response se order id — shape SUPER-lenient (id / orderId /
        // order_number / root num / root string). User screenshot me Order
        // Number BLANK aaya tha (server data:null ya alag key bhejta hai).
        // [isRealNo] = order_number se aaya (Track Order → detail GetOrder
        // isi se chalta hai); PK id ho to false.
        int orderId = 0;
        bool isRealNo = false;
        try {
          dynamic d = res.data;
          if (d is num) orderId = d.toInt();
          if (orderId == 0 && d is String) {
            orderId = int.tryParse(d) ?? 0;
          }
          var tentativeId = 0;
          for (var i = 0; i < 4 && d is Map && orderId == 0; i++) {
            final m = Map<String, dynamic>.from(d as Map);
            // DISPLAY consistency: order# PEHLE (history card bhi wahi
            // dikhati hai — success "#42" vs history "#1042" mismatch na
            // ho), phir PK id.
            final v = m['order_number'] ??
                m['Order_Number'] ??
                m['orderNumber'] ??
                m['number'] ??
                m['Number'];
            if (v != null) {
              orderId = int.tryParse(v.toString()) ?? 0;
              isRealNo = orderId > 0;
              break;
            }
            // PK sirf TENTATIVE rakho — nested {order:{order_number}} me
            // asli number ho sakta hai, pehle woh dhoondo.
            if (tentativeId == 0) {
              final v2 = m['id'] ??
                  m['Id'] ??
                  m['order_id'] ??
                  m['Order_Id'] ??
                  m['orderId'] ??
                  m['OrderId'];
              tentativeId = int.tryParse(v2?.toString() ?? '') ?? 0;
            }
            d = m['data'] ?? m['Data'] ?? m['order'] ?? m['Order'];
          }
          if (orderId == 0) orderId = tentativeId;
        } catch (_) {}
        // FALLBACK (deep-fix): response me number nahi mila to NAYI row
        // dhundho — wo row jo place karne se PEHLE ke snapshot me nahi
        // thi. Server order_number thodi der baad bhi assign karta hai,
        // isliye ~9 sec tak poll karo: pehle PK se NAYI row pakdo, phir
        // usi row me number aane ka intezaar. Kisi PURANE order ka number
        // ab dikhna NA-MUMKIN hai.
        if (orderId == 0) {
          int newPk = 0;
          for (var attempt = 0; attempt < 6 && orderId == 0; attempt++) {
            if (attempt > 0) {
              await Future.delayed(const Duration(milliseconds: 1500));
            }
            final rows = await _fetchOrderRows();
            Map<String, dynamic>? fresh;
            if (newPk > 0) {
              // nayi row pehchani jaa chuki — ab usi me number ka intezaar
              for (final r in rows) {
                if (_rowPk(r) == newPk) {
                  fresh = r;
                  break;
                }
              }
            } else {
              // list newest-first aati hai — snapshot ke BAHAR wali pehli
              // row hi abhi-just-placed order hai.
              for (final r in rows) {
                final pk = _rowPk(r);
                if (pk > 0 && !beforePks.contains(pk)) {
                  fresh = r;
                  newPk = pk;
                  break;
                }
              }
            }
            final no = fresh == null ? 0 : _rowOrderNumber(fresh);
            if (no > 0) {
              orderId = no;
              isRealNo = true;
            }
          }
          // number mil gaya to THEEK; nahi mila par nayi row pakki hai to
          // uska PK dikhao (history card bhi wahi PK fallback dikhati hai
          // — dono jagah SAME rahega, kisi doosre order ka nahi).
          if (orderId == 0) orderId = newPk;
        }
        lastPlacedOrder = {
          'items': snapItems,
          'total': preRefreshTotal != '0' ? preRefreshTotal : _currentTotal(),
          'orderId': orderId,
          'isOrderNumber': isRealNo,
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
        // order SUCCESS ke baad snapshot CLEAR — warna agli baar place par
        // yahi placed items ghost ban kar dobara order ho jayenge.
        await CartController.clearCartSnapshot();
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
