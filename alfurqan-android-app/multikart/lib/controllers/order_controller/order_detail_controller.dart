import '../../config.dart';
import '../../models/json_parse_utils.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// ORDER DETAIL — pehle yaha STATIC demo data tha (fake timeline, fake
/// address, cartList demo products). Ab order history se aaye REAL order id
/// se `GET api/Orders/GetOrder?id=` call karke LIVE detail dikhata hai:
/// items, status timeline, shipping address, price breakup.
class OrderDetailController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  TextEditingController controller = TextEditingController();

  // ---------------- Request state ----------------
  int orderId = 0;
  bool isLoading = false;
  bool loadFailed = false;

  // ---------------- Parsed detail (view yahi padhta hai) ----------------
  String orderNumber = '';
  String orderDate = '';
  String status = '';
  double subtotal = 0;
  double shipping = 0;
  double discount = 0;
  double tax = 0;
  double total = 0;
  // OrdersDto ke extra money/payment fields (server verify: wallet_balance,
  // points_amount, payment_method, payment_status / entity camelCase)
  double walletUsed = 0;
  double pointsUsed = 0;
  String paymentMethod = '';
  String paymentStatus = '';

  /// items: {name, image, qty, price, lineTotal}
  List<Map<String, dynamic>> items = [];

  /// timeline: {name, date, note, done}
  List<Map<String, dynamic>> timeline = [];

  /// shipping address: {name, line1, city, state, country, phone}
  Map<String, dynamic> address = {};

  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  // Issue#9: order history se aaya summary (api fail hone par bhi detail
  // khaali/white screen na dikhe — isi se turant prefill hota hai).
  bool _prefilledFromSummary = false;
  // Prefill ka backup — api response agar KHAALI products/total de (server
  // kabhi slim shape deta hai) to REAL summary wale items hi dikhate rahe.
  List<Map<String, dynamic>> _prefillItems = [];
  double _prefillTotal = 0;
  String _prefillStatus = '';

  @override
  void onReady() {
    // order history se {'id': 123, 'summary': OrderHistoryModel} aata hai;
    // purane kisi caller ne seedha int bheja ho to wo bhi handle.
    final args = Get.arguments;
    if (args is Map) {
      orderId = int.tryParse(args['id']?.toString() ?? '') ?? 0;
      if (args['summary'] is OrderHistoryModel) {
        _prefillFromSummary(args['summary'] as OrderHistoryModel);
      }
    } else if (args is num) {
      orderId = args.toInt();
    }
    if (orderId > 0) {
      fetchOrderDetail();
    } else if (!_prefilledFromSummary) {
      loadFailed = true;
    }
    update();
    super.onReady();
  }

  /// History list wale REAL row se turant detail bharo — api GetOrder ka
  /// fresh data aane par ye overwrite ho jayega; api fail ho jaye to bhi
  /// user ko uske order ka asli naam/qty/amount/status dikhta rahega
  /// (blank white screen + "load nahi ho paya" NAHI — Issue #9).
  void _prefillFromSummary(OrderHistoryModel o) {
    _prefilledFromSummary = true;
    orderNumber = (o.orderId ?? 0) > 0 ? '${o.orderId}' : '';
    orderDate = o.orderDay ?? '';
    final list = o.daysWiseList ?? const <DaysWiseList>[];
    items = list.map((it) {
      // 'AED 45.00' jaisi price string se number nikaalo
      final totalStr = (it.size ?? '');
      final lineTotal = double.tryParse(
              totalStr.replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      final qty = it.qty ?? 1;
      final unit = qty > 0 ? lineTotal / qty : lineTotal;
      return <String, dynamic>{
        'name': it.name ?? '',
        'image': it.image ?? '',
        'qty': qty,
        'price': unit,
        'lineTotal': lineTotal,
      };
    }).toList();
    if (list.isNotEmpty) {
      status = (list.first.status ??
              list.first.deliveryStatus ??
              '')
          .toString();
      // pehli line ka total ko grand total maano (history row me total
      // wahi hota hai); api aane par sahi breakup aa jayega.
      final t = double.tryParse(
              (list.first.size ?? '').replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0;
      if (t > 0) {
        subtotal = t;
        total = t;
      }
    }
    _prefillItems = List<Map<String, dynamic>>.from(items);
    _prefillTotal = total;
    _prefillStatus = status;
  }

  Future<void> fetchOrderDetail() async {
    // prefill ho chuka ho to data dikhte hue background me refresh karo —
    // poora spinner wali white screen NAHI (Issue #9).
    isLoading = !_prefilledFromSummary;
    loadFailed = false;
    update();
    try {
      final res = await ApiService().request<Map<String, dynamic>>(
        endpoint: ApiEndpoints.getOrder,
        method: ApiMethod.get,
        queryParams: {'id': orderId.toString()},
        fromJson: (json) {
          dynamic raw = json;
          // envelope {data:{order}} ya seedha order map — lenient unwrap
          for (var i = 0; i < 3 && raw is Map; i++) {
            final m = Map<String, dynamic>.from(raw as Map);
            if (m.containsKey('items') ||
                m.containsKey('order_items') ||
                m.containsKey('Order_Items') ||
                m.containsKey('total') ||
                m.containsKey('Total') ||
                m.containsKey('order_number') ||
                m.containsKey('Order_Number')) {
              return m;
            }
            raw = m['data'] ?? m['Data'] ?? m['order'] ?? m['Order'];
            if (raw == null) return m;
          }
          return raw is Map
              ? Map<String, dynamic>.from(raw as Map)
              : <String, dynamic>{};
        },
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        _parse(res.data!);
      } else if (!_prefilledFromSummary) {
        // Issue#9: summary se prefill ho chuka hai to ERROR screen mat
        // dikhao — real order data pehle se dikh raha hai.
        loadFailed = true;
      }
    } catch (_) {
      if (!_prefilledFromSummary) loadFailed = true;
    }
    isLoading = false;
    update();
  }

  /// MediaFiles {asset_url, original_url} (swagger verify) — 'url' key hoti
  /// hi nahi, isliye pehle order items ki image HAMESHA khaali aati thi.
  static String _mediaUrl(dynamic m) {
    if (m is Map) {
      final mm = Map<String, dynamic>.from(m);
      return jsonToString(mm['asset_url'] ??
              mm['original_url'] ??
              mm['url'] ??
              mm['image_Url'] ??
              mm['ImageUrl']) ??
          '';
    }
    return jsonToString(m) ?? '';
  }

  /// SERVER-SCHEMA parse — alfurqan.ae swagger v2 (/swagger/v2/swagger.json)
  /// se VERIFY kiya hua. GetOrder 2 shapes me aa sakta hai:
  ///  • OrdersDto (snake_case): products[] = {name, sale_price, price,
  ///    pivot:{quantity, single_price, subtotal}, product_thumbnail{..}}
  ///  • OrderMst entity (camelCase): products[] = {product:{name,
  ///    product_thumbnail{..}}, quantity, price, subTotal}
  /// Pehle parser pivot/entity/camelCase in sabko MISS karta tha — isliye
  /// detail page par "kuch nahi" (empty items / AED 0.00) dikh raha tha.
  void _parse(Map<String, dynamic> j) {
    // ---- order number / date ----
    orderNumber = jsonToString(j['order_number'] ??
            j['Order_Number'] ??
            j['orderNumber'] ??
            j['order_no'] ??
            j['orderNo'] ??
            j['orderid'] ??
            j['id']) ??
        '';
    orderDate = jsonToString(j['created_at'] ??
            j['Created_at'] ??
            j['createdAt'] ??
            j['order_date'] ??
            j['date']) ??
        '';
    if (orderDate.length >= 10) orderDate = orderDate.substring(0, 10);

    // ---- status (order_status{name} / orderStatus{name} / status text) ----
    final st = j['order_status'] ?? j['Order_Status'] ?? j['orderStatus'];
    if (st is Map) {
      status = jsonToString(st['name'] ?? st['Name'] ?? st['title'] ?? st['slug']) ?? '';
    } else {
      status = jsonToString(
              j['status_name'] ?? j['Status_Name'] ?? j['status'] ?? st) ??
          '';
    }
    // entity me 'status' boolean hota hai — numeric/bool status mat dikhao
    if (status == 'true' || status == 'false') status = '';

    // ---- totals (OrdersDto: amount=subtotal, total=grand) ----
    subtotal = jsonToDouble(j['amount'] ??
            j['Amount'] ??
            j['sub_total'] ??
            j['Sub_Total'] ??
            j['subtotal']) ??
        0;
    shipping = jsonToDouble(j['shipping_total'] ??
            j['shippingTotal'] ??
            j['Shipping_Total'] ??
            j['shipping_cost'] ??
            j['Shipping_Cost'] ??
            j['shipping']) ??
        0;
    discount = jsonToDouble(j['coupon_total_discount'] ??
            j['couponTotalDiscount'] ??
            j['Coupon_Total_Discount'] ??
            j['discount'] ??
            j['Discount'] ??
            j['coupon_amount']) ??
        0;
    tax = jsonToDouble(
            j['tax_total'] ?? j['taxTotal'] ?? j['Tax_Total'] ?? j['tax'] ?? j['Tax']) ??
        0;
    total = jsonToDouble(j['total'] ??
            j['Total'] ??
            j['grand_total'] ??
            j['Grand_Total']) ??
        (subtotal + shipping + tax - discount);
    walletUsed = jsonToDouble(j['wallet_balance'] ??
            j['walletBalance'] ??
            j['wallet_amount']) ??
        0;
    pointsUsed = jsonToDouble(j['points_amount'] ??
            j['pointsAmount'] ??
            j['points']) ??
        0;
    paymentMethod = jsonToString(j['payment_method'] ??
            j['paymentMethod'] ??
            j['Payment_Method']) ??
        '';
    paymentStatus = jsonToString(j['payment_status'] ??
            j['paymentStatus'] ??
            j['Payment_Status']) ??
        '';

    // ---- items: products[] (server) — pivot se REAL qty/price ----
    dynamic rawItems = j['products'] ??
        j['Products'] ??
        j['items'] ??
        j['order_items'] ??
        j['Order_Items'];
    // multi-store: items parent me na ho to pehle sub_order se lo
    if (rawItems is! List || rawItems.isEmpty) {
      final subs = j['sub_orders'] ?? j['subOrders'];
      if (subs is List && subs.isNotEmpty && subs.first is Map) {
        final s0 = Map<String, dynamic>.from(subs.first as Map);
        rawItems = s0['products'] ?? s0['Products'] ?? s0['items'];
      }
    }
    items = [];
    if (rawItems is List) {
      double sum = 0;
      for (final e in rawItems) {
        if (e is! Map) continue;
        final it = Map<String, dynamic>.from(e);
        final prod = it['product'] is Map
            ? Map<String, dynamic>.from(it['product'] as Map)
            : (it['Product'] is Map
                ? Map<String, dynamic>.from(it['Product'] as Map)
                : <String, dynamic>{});
        final pivot = it['pivot'] is Map
            ? Map<String, dynamic>.from(it['pivot'] as Map)
            : (it['Pivot'] is Map
                ? Map<String, dynamic>.from(it['Pivot'] as Map)
                : <String, dynamic>{});
        final qty = jsonToInt(pivot['quantity'] ??
                it['quantity'] ??
                it['qty'] ??
                it['Quantity']) ??
            1;
        final price = jsonToDouble(pivot['single_price'] ??
                pivot['singlePrice'] ??
                it['single_price'] ??
                it['price'] ??
                it['Price'] ??
                prod['price'] ??
                it['sale_price']) ??
            0;
        final line = jsonToDouble(pivot['subtotal'] ??
                pivot['subTotal'] ??
                it['subtotal'] ??
                it['subTotal'] ??
                it['sub_total'] ??
                it['Sub_Total']) ??
            (price * qty);
        sum += line;
        String img = _mediaUrl(it['product_thumbnail']);
        if (img.isEmpty) img = _mediaUrl(it['variation_image']);
        if (img.isEmpty) {
          img = jsonToString(it['image'] ??
                  it['Image'] ??
                  it['image_url'] ??
                  it['ImageUrl'] ??
                  prod['image'] ??
                  prod['ImageUrl'] ??
                  prod['thumbnail']) ??
              '';
        }
        if (img.isEmpty) img = _mediaUrl(prod['product_thumbnail']);
        items.add({
          'name': jsonToString(it['name'] ??
                  it['Name'] ??
                  it['product_name'] ??
                  prod['name'] ??
                  prod['Name']) ??
              'Item',
          'image': buildMediaUrl(img),
          'qty': qty,
          'price': price,
          'lineTotal': line,
        });
      }
      if (subtotal <= 0 && sum > 0) subtotal = sum;
    }

    // ---- status timeline: order_status_activities (DTO: status string,
    // changed_at) / orderStatusActivities (entity: orderStatus{name},
    // changed_At) — dono. Date ke hisaab se sort (purana → naya). ----
    dynamic rawActs = j['order_status_activities'] ??
        j['Order_Status_Activities'] ??
        j['orderStatusActivities'] ??
        j['status_activities'] ??
        j['Status_Activities'] ??
        j['activities'];
    timeline = [];
    if (rawActs is List) {
      for (final e in rawActs) {
        if (e is! Map) continue;
        final a = Map<String, dynamic>.from(e);
        dynamic stMap = a['orderStatus'] ??
            a['OrderStatus'] ??
            a['order_status'] ??
            a['status'];
        String nm = stMap is Map
            ? (jsonToString(Map<String, dynamic>.from(stMap)['name'] ??
                    Map<String, dynamic>.from(stMap)['Name']) ??
                '')
            : (jsonToString(stMap) ?? '');
        if (nm == 'true' || nm == 'false') nm = '';
        timeline.add({
          'name': nm.isNotEmpty ? nm : status,
          'date': jsonToString(a['changed_At'] ??
                  a['changed_at'] ??
                  a['changedAt'] ??
                  a['created_at'] ??
                  a['createdAt'] ??
                  a['date']) ??
              '',
          'note': jsonToString(a['note'] ?? a['Note']) ?? '',
        });
      }
      timeline.sort((a, b) {
        final da = DateTime.tryParse((a['date'] ?? '').toString()) ??
            DateTime(2000);
        final db = DateTime.tryParse((b['date'] ?? '').toString()) ??
            DateTime(2000);
        return da.compareTo(db);
      });
    }
    // timeline khaali ho to kam se kam current status ki ek entry dikhao
    if (timeline.isEmpty && status.isNotEmpty) {
      timeline.add({'name': status, 'date': orderDate, 'note': ''});
    }

    // ---- shipping address (AddressDto: title/street/city/stateName/
    // state{name}/country{name}/pincode/phone(int64!)/country_code;
    // entity Addresses: street/city/state{}/country{}/pincode(int)/
    // phone(string)) ----
    dynamic rawAddr = j['shipping_address'] ??
        j['Shipping_Address'] ??
        j['shippingAddress'] ??
        j['address'] ??
        j['Address'];
    if (rawAddr is List && rawAddr.isNotEmpty) rawAddr = rawAddr.first;
    address = {};
    if (rawAddr is Map) {
      final m = Map<String, dynamic>.from(rawAddr);
      String stateName =
          jsonToString(m['stateName'] ?? m['state_name']) ?? '';
      if (stateName.isEmpty && m['state'] is Map) {
        final sm = Map<String, dynamic>.from(m['state'] as Map);
        stateName = jsonToString(sm['name'] ?? sm['Name']) ?? '';
      }
      if (stateName.isEmpty && m['State'] is String) {
        stateName = jsonToString(m['State']) ?? '';
      }
      String countryName = '';
      if (m['country'] is Map) {
        final cm = Map<String, dynamic>.from(m['country'] as Map);
        countryName = jsonToString(cm['name'] ?? cm['Name']) ?? '';
      } else if (m['Country'] is Map) {
        final cm = Map<String, dynamic>.from(m['Country'] as Map);
        countryName = jsonToString(cm['name'] ?? cm['Name']) ?? '';
      } else {
        countryName = jsonToString(m['country'] ?? m['Country']) ?? '';
      }
      // phone AddressDto me int64 hota hai, entity me string — dono safe
      final cc = jsonToString(m['country_code'] ?? m['countryCode']) ?? '';
      String ph = jsonToString(m['phone'] ?? m['Phone'] ?? m['mobile']) ?? '';
      // double "971551234567.0" jaisa aa jaye to int part lo
      if (ph.contains('.')) {
        ph = ph.split('.').first;
      }
      String phone = ph;
      if (ph.isNotEmpty &&
          cc.isNotEmpty &&
          !ph.startsWith(cc) &&
          !ph.startsWith('+$cc') &&
          !ph.startsWith('0$cc')) {
        phone = '+$cc $ph';
      }
      // recipient naam: consumer_name / consumer{name} / address user/title
      String recipient = jsonToString(
              j['consumer_name'] ?? j['consumerName'] ?? j['customer_name']) ??
          '';
      if (recipient.isEmpty && j['consumer'] is Map) {
        final cu = Map<String, dynamic>.from(j['consumer'] as Map);
        recipient = jsonToString(
                cu['name'] ?? cu['Name'] ?? cu['userName'] ?? cu['username']) ??
            '';
      }
      if (recipient.isEmpty && j['user'] is Map) {
        final cu = Map<String, dynamic>.from(j['user'] as Map);
        recipient = jsonToString(cu['name'] ?? cu['Name']) ?? '';
      }
      if (recipient.isEmpty) {
        recipient = jsonToString(
                m['name'] ?? m['Name'] ?? m['full_name'] ?? m['fullName']) ??
            '';
      }
      address = {
        'name': recipient,
        'title': jsonToString(m['title'] ?? m['Title']) ?? '',
        'line1': jsonToString(m['street'] ??
                m['address'] ??
                m['Address'] ??
                m['address_line_1'] ??
                m['line1']) ??
            '',
        'city': jsonToString(m['city'] ?? m['City']) ?? '',
        'state': stateName,
        'country': countryName,
        'pincode': jsonToString(
                m['pincode'] ?? m['Pincode'] ?? m['zip'] ?? m['zipcode']) ??
            '',
        'phone': phone,
      };
      // poora khaali ho to section hi hide (khaali card na dikhe)
      if (address.values.every((v) => (v ?? '').toString().isEmpty)) {
        address = {};
      }
    }

    // ---- server khaali/slim de to prefill (REAL summary) restore ----
    if (items.isEmpty && _prefillItems.isNotEmpty) {
      items = List<Map<String, dynamic>>.from(_prefillItems);
    }
    if (total <= 0 && _prefillTotal > 0) {
      total = _prefillTotal;
      if (subtotal <= 0) subtotal = _prefillTotal;
    }
    if (status.isEmpty && _prefillStatus.isNotEmpty) {
      status = _prefillStatus;
    }
  }
}
