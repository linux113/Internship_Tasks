import '../../config.dart';
import '../../models/json_parse_utils.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// Order History — pehle STATIC demo orders dikhata tha (kapdon ke fake
/// orders!). Ab api/Orders/GetUserOrders (login user ke real orders).
/// Server ka exact row shape badal sakta hai, isliye parsing lenient hai
/// (snake_case/PascalCase dono). Koi order nahi / guest ho to clean
/// "No orders yet" state dikhti hai (fake data nahi).
class OrderHistoryController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  TextEditingController controller = TextEditingController();
  List<OrderHistoryModel> orderHistoryList = [];
  List orderType = [];
  List timeFilterType = [];
  int orderTypeValue = 0;
  int timeFilterTypeValue = 0;

  // ACTUALLY-APPLIED filter values (radio sirf pending selection hai —
  // APPLY dabane par yaha copy hota hai). Pehle APPLY button sirf
  // Get.back() karta tha, filter kuch nahi karta tha (decorative tha!).
  int appliedOrderType = 0;
  int appliedTimeFilter = 0;

  /// Search box ka live text (order number / item name / status se match).
  String searchQuery = '';

  bool isLoadingOrders = false;

  /// Guest ho to true — view "Please login to see your orders" dikhayegi.
  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  @override
  void onReady() {
    orderHistoryList = []; // demo orders hata diye — real api se bharenge
    orderType = AppArray().orderType;
    timeFilterType = AppArray().timeFilterType;
    // FIX: search box pehle decorative tha (type karne par kuch nahi hota
    // tha). Ab har keystroke par visibleOrders filter hoti hai.
    controller.addListener(() {
      searchQuery = controller.text;
      update();
    });
    update();
    fetchOrders();
    super.onReady();
  }

  /// Issue#10: backend date formats mix ho sakte hai — ISO (2026-07-21),
  /// dd-MM-yyyy, dd/MM/yyyy sab try karo. Na mile to null (filter use skip).
  static DateTime? _parseOrderDate(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final m = RegExp(r'^(\d{1,2})[-/](\d{1,2})[-/](\d{4})$').firstMatch(s);
    if (m != null) {
      final d = int.tryParse(m.group(1)!) ?? 1;
      final mo = int.tryParse(m.group(2)!) ?? 1;
      final y = int.tryParse(m.group(3)!) ?? 2000;
      return DateTime(y, mo, d);
    }
    return null;
  }

  /// APPLY button — pending radio selection ko lagoo karo aur UI refresh.
  void applyFilters() {
    appliedOrderType = orderTypeValue;
    appliedTimeFilter = timeFilterTypeValue;
    update();
  }

  /// Applied filters ke hisaab se dikhne wale orders (client-side filter —
  /// backend ko filter param support nahi karta, isliye yahi sahi jagah hai).
  List<OrderHistoryModel> get visibleOrders {
    var list = orderHistoryList;

    // Live search (order id / date / item name / status — case-insensitive)
    final q = searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((o) {
        if ((o.orderId?.toString() ?? '').contains(q)) return true;
        if ((o.orderDay ?? '').toLowerCase().contains(q)) return true;
        final items = o.daysWiseList ?? const <DaysWiseList>[];
        return items.any((it) =>
            (it.name ?? '').toLowerCase().contains(q) ||
            (it.status ?? '').toLowerCase().contains(q) ||
            (it.deliveryStatus ?? '').toLowerCase().contains(q));
      }).toList();
    }

    // Type filter: 0=All, 1=Open, 2=Return, 3=Cancelled
    if (appliedOrderType != 0) {
      list = list.where((o) {
        final first = (o.daysWiseList?.isNotEmpty == true)
            ? o.daysWiseList!.first
            : null;
        final s = (first?.status ?? first?.deliveryStatus ?? '')
            .toString()
            .toLowerCase();
        // Issue#10: backend status words vary karte hai (delivered/completed/
        // cancel/refund/return...) — saare variants cover karo.
        final isClosed = s.contains('deliver') ||
            s.contains('complet') ||
            s.contains('success') ||
            s.contains('cancel') ||
            s.contains('reject') ||
            s.contains('return') ||
            s.contains('refund');
        switch (appliedOrderType) {
          case 1: // Open — kisi bhi "closed" category me nahi
            return !isClosed;
          case 2:
            return s.contains('return') || s.contains('refund');
          case 3:
            return s.contains('cancel') || s.contains('reject');
          default:
            return true;
        }
      }).toList();
    }

    // Time filter: 0=All Time, 1=Last 30 Days, 2=Last 6 Months
    if (appliedTimeFilter != 0) {
      final cutoff = DateTime.now()
          .subtract(Duration(days: appliedTimeFilter == 1 ? 30 : 182));
      list = list.where((o) {
        final d = _parseOrderDate(o.orderDay ?? '');
        // Issue#10: date parse na ho to order CHIPAHO mat (user ko laga
        // "filter sab gayab kar deta hai") — unknown date waale hamesha dikhte hai.
        if (d == null) return true;
        return !d.isBefore(cutoff);
      }).toList();
    }
    return list;
  }

  /// Real orders laao (token se — backend khud user identify karta hai).
  Future<void> fetchOrders() async {
    if (!isLoggedIn) {
      orderHistoryList = [];
      update();
      return;
    }
    isLoadingOrders = true;
    update();
    try {
      final res = await ApiService().request<List<OrderHistoryModel>>(
        endpoint: ApiEndpoints.getUserOrders,
        method: ApiMethod.get,
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['orders'] ?? raw['Orders'] ?? raw['items'];
          }
          if (raw is! List) return <OrderHistoryModel>[];
          return raw
              .where((e) => e is Map)
              .map((e) => _rowToModel(Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
      if (res.isSuccess && res.data != null) {
        orderHistoryList = res.data!;
      }
    } catch (_) {}
    isLoadingOrders = false;
    update();
  }

  /// Ek order row ko view-model me map karo (shape lenient).
  OrderHistoryModel _rowToModel(Map<String, dynamic> j) {
    final id = j['id'] ?? j['Id'] ?? j['order_id'] ?? j['Order_Id'];
    final orderNo =
        (j['order_number'] ?? j['Order_Number'] ?? j['order_no'] ?? id)?.toString() ?? '';
    final date = (j['created_at'] ??
            j['Created_at'] ??
            j['createdAt'] ??
            j['order_date'] ??
            j['date'] ??
            '')
        .toString();
    String status = '';
    final st = j['order_status'] ?? j['Order_Status'];
    if (st is Map) {
      status = (st['name'] ?? st['Name'] ?? st['title'] ?? '').toString();
    } else {
      status = (j['status_name'] ??
              j['Status_Name'] ??
              j['status'] ??
              st ??
              '')
          .toString();
    }
    final total = jsonToDouble(
        j['total'] ?? j['Total'] ?? j['grand_total'] ?? j['Grand_Total'] ?? j['amount']);
    List items = const [];
    if (j['items'] is List) items = j['items'] as List;
    if (items.isEmpty && j['order_items'] is List) items = j['order_items'] as List;
    if (items.isEmpty && j['Order_Items'] is List) items = j['Order_Items'] as List;

    // pehle item ki image (ho to) card me lagao
    String image = '';
    if (items.isNotEmpty && items.first is Map) {
      final it = Map<String, dynamic>.from(items.first as Map);
      image = jsonToString(it['image'] ??
              it['Image'] ??
              it['image_url'] ??
              it['ImageUrl'] ??
              (it['product'] is Map
                  ? (it['product']['image'] ?? it['product']['ImageUrl'])
                  : null)) ??
          '';
    }

    return OrderHistoryModel(
      orderId: jsonToInt(id),
      orderDay: date.length >= 10 ? date.substring(0, 10) : date,
      daysWiseList: [
        for (var i = 0; i < (items.isEmpty ? 1 : items.length); i++)
          () {
            String itemName = 'Order #$orderNo';
            if (items.isNotEmpty && items[i] is Map) {
              final it = Map<String, dynamic>.from(items[i] as Map);
              itemName = jsonToString(it['name'] ??
                      it['Name'] ??
                      it['product_name'] ??
                      (it['product'] is Map
                          ? (it['product']['name'] ?? it['product']['Name'])
                          : null)) ??
                  itemName;
            }
            return DaysWiseList(
              image: i == 0 ? buildMediaUrl(image) : '',
              name: itemName,
              size: total != null && i == 0 ? 'AED ${total.toStringAsFixed(2)}' : '',
              qty: items.isNotEmpty && items[i] is Map
                  ? (jsonToInt(Map<String, dynamic>.from(items[i] as Map)['quantity'] ??
                          Map<String, dynamic>.from(items[i] as Map)['qty']) ??
                      1)
                  : 1,
              date: date,
              deliveryStatus: status,
              status: status,
            );
          }()
      ],
    );
  }

  //common bottom sheet
  bottomSheetLayout() {
    Get.bottomSheet(
      const RatingReview(),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }

  //order history filter bottom sheet
  historyFilterBottomSheet() {
    // sheet khulne par radio = pehle se APPLIED filter dikhao (warna har
    // baar "All" reset dikhta, jabki list filtered rehti — mismatch bug).
    orderTypeValue = appliedOrderType;
    timeFilterTypeValue = appliedTimeFilter;
    update();
    Get.bottomSheet(
      const OrderHistoryFilter(),
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
    );
  }
}
