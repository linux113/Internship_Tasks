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

  bool isLoadingOrders = false;

  /// Guest ho to true — view "Please login to see your orders" dikhayegi.
  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  @override
  void onReady() {
    orderHistoryList = []; // demo orders hata diye — real api se bharenge
    orderType = AppArray().orderType;
    timeFilterType = AppArray().timeFilterType;
    update();
    fetchOrders();
    super.onReady();
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
