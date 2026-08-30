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

  /// items: {name, image, qty, price, lineTotal}
  List<Map<String, dynamic>> items = [];

  /// timeline: {name, date, note, done}
  List<Map<String, dynamic>> timeline = [];

  /// shipping address: {name, line1, city, state, country, phone}
  Map<String, dynamic> address = {};

  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  @override
  void onReady() {
    // order history se {'id': 123} aata hai; purane kisi caller ne seedha
    // int bheja ho to wo bhi handle.
    final args = Get.arguments;
    if (args is Map) {
      orderId = int.tryParse(args['id']?.toString() ?? '') ?? 0;
    } else if (args is num) {
      orderId = args.toInt();
    }
    if (orderId > 0) {
      fetchOrderDetail();
    } else {
      loadFailed = true;
    }
    update();
    super.onReady();
  }

  Future<void> fetchOrderDetail() async {
    isLoading = true;
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
      } else {
        loadFailed = true;
      }
    } catch (_) {
      loadFailed = true;
    }
    isLoading = false;
    update();
  }

  void _parse(Map<String, dynamic> j) {
    orderNumber = jsonToString(j['order_number'] ??
            j['Order_Number'] ??
            j['order_no'] ??
            j['orderNo'] ??
            j['id']) ??
        '';
    orderDate = jsonToString(j['created_at'] ??
            j['Created_at'] ??
            j['order_date'] ??
            j['date']) ??
        '';

    // ---- status ----
    final st = j['order_status'] ?? j['Order_Status'];
    if (st is Map) {
      status = jsonToString(st['name'] ?? st['Name'] ?? st['title']) ?? '';
    } else {
      status = jsonToString(
              j['status_name'] ?? j['Status_Name'] ?? j['status'] ?? st) ??
          '';
    }

    // ---- totals ----
    subtotal = jsonToDouble(j['sub_total'] ??
            j['Sub_Total'] ??
            j['subtotal'] ??
            j['amount'] ??
            j['total']) ??
        0;
    shipping = jsonToDouble(
            j['shipping_cost'] ?? j['Shipping_Cost'] ?? j['shipping']) ??
        0;
    discount = jsonToDouble(
            j['discount'] ?? j['Discount'] ?? j['coupon_amount']) ??
        0;
    tax = jsonToDouble(j['tax'] ?? j['Tax']) ?? 0;
    total = jsonToDouble(j['total'] ??
            j['Total'] ??
            j['grand_total'] ??
            j['Grand_Total']) ??
        (subtotal + shipping + tax - discount);

    // ---- items ----
    dynamic rawItems = j['items'] ??
        j['order_items'] ??
        j['Order_Items'] ??
        j['products'] ??
        j['Products'];
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
        final qty = jsonToInt(it['quantity'] ?? it['qty'] ?? it['Quantity']) ?? 1;
        final price = jsonToDouble(it['price'] ?? it['Price'] ?? prod['price']) ?? 0;
        final line = jsonToDouble(it['sub_total'] ?? it['subTotal'] ?? it['Sub_Total']) ??
            (price * qty);
        sum += line;
        String img = jsonToString(it['image'] ??
                it['Image'] ??
                prod['image'] ??
                prod['ImageUrl'] ??
                prod['thumbnail']) ??
            '';
        if (img.isEmpty && prod['product_thumbnail'] is Map) {
          img = jsonToString(
                  Map<String, dynamic>.from(prod['product_thumbnail'] as Map)['url']) ??
              '';
        }
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

    // ---- status timeline (OrderStatusActivities) ----
    dynamic rawActs = j['status_activities'] ??
        j['Status_Activities'] ??
        j['order_status_activities'] ??
        j['Order_Status_Activities'] ??
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
        timeline.add({
          'name': nm.isNotEmpty ? nm : status,
          'date': jsonToString(a['changed_At'] ??
                  a['changed_at'] ??
                  a['created_at'] ??
                  a['date']) ??
              '',
          'note': jsonToString(a['note'] ?? a['Note']) ?? '',
        });
      }
    }
    // timeline khaali ho to kam se kam current status ki ek entry dikhao
    if (timeline.isEmpty && status.isNotEmpty) {
      timeline.add({'name': status, 'date': orderDate, 'note': ''});
    }

    // ---- shipping address ----
    dynamic rawAddr = j['shipping_address'] ??
        j['Shipping_Address'] ??
        j['shippingAddress'] ??
        j['address'] ??
        j['Address'];
    if (rawAddr is List && rawAddr.isNotEmpty) rawAddr = rawAddr.first;
    if (rawAddr is Map) {
      final m = Map<String, dynamic>.from(rawAddr);
      address = {
        'name': jsonToString(m['name'] ?? m['Name'] ?? m['full_name']) ?? '',
        'line1': jsonToString(m['address'] ??
                m['Address'] ??
                m['address_line_1'] ??
                m['line1']) ??
            '',
        'city': jsonToString(m['city'] ?? m['City']) ?? '',
        'state': jsonToString(m['state'] ?? m['State']) ?? '',
        'country': jsonToString(m['country'] ?? m['Country']) ?? '',
        'phone': jsonToString(m['phone'] ?? m['Phone'] ?? m['mobile']) ?? '',
      };
    }
  }
}
