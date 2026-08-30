import '../../config.dart';
import '../../models/json_parse_utils.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// Payment (Card & Balance) page — pehle STATIC demo cards + fake wallet
/// balance dikhata tha. Ab: saved-cards ka koi api nahi hai (cards store hi
/// nahi hote backend par) isliye "No saved cards" dikhta hai, aur wallet
/// balance api/Wallet_Point/GetWallet se REAL aata hai.
class CardBalanceController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  int currentIndex = 0;

  /// Real wallet balance (null = fetch fail / guest)
  double? walletBalance;
  bool isLoadingWallet = false;

  /// Wallet/Points transactions (api/Wallet_Point/GetPoints) —
  /// har row: {title, date, amount}
  List<Map<String, dynamic>> pointsList = [];
  bool isLoadingPoints = false;

  bool get isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  int get _userId {
    final raw = storage.read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  @override
  void onReady() {
    fetchWalletBalance();
    fetchPointsHistory();
    super.onReady();
  }

  /// GetPoints — wallet points ki transactions list (lenient parse).
  Future<void> fetchPointsHistory() async {
    if (!isLoggedIn) return;
    isLoadingPoints = true;
    update();
    try {
      final res = await ApiService().request<List<Map<String, dynamic>>>(
        endpoint: ApiEndpoints.getPoints,
        method: ApiMethod.get,
        queryParams: {'consumer_id': _userId, 'page': 1, 'paginate': 15},
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'];
          }
          if (raw is! List) return <Map<String, dynamic>>[];
          return raw.where((e) => e is Map).map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            return <String, dynamic>{
              'title': (jsonToString(m['title'] ??
                      m['Title'] ??
                      m['type'] ??
                      m['description'] ??
                      m['Description']) ??
                  'Points'),
              'date': jsonToString(m['created_at'] ??
                      m['Created_at'] ??
                      m['date'] ??
                      m['Date']) ??
                  '',
              'amount': jsonToDouble(m['amount'] ??
                      m['Amount'] ??
                      m['points'] ??
                      m['Points'] ??
                      m['balance']) ??
                  0,
            };
          }).toList();
        },
      );
      if (res.isSuccess && res.data != null) {
        pointsList = res.data!;
      }
    } catch (_) {}
    isLoadingPoints = false;
    update();
  }

  /// GetWallet — response shape badal sakta hai, lenient parse.
  Future<void> fetchWalletBalance() async {
    if (!isLoggedIn) return;
    isLoadingWallet = true;
    update();
    try {
      final res = await ApiService().request<double?>(
        endpoint: ApiEndpoints.getWallet,
        method: ApiMethod.get,
        queryParams: {'consumer_id': _userId, 'paginate': 15},
        fromJson: (json) {
          // seedha number ya map me balance/total dhundo
          if (json is num) return json.toDouble();
          if (json is Map) {
            final m = Map<String, dynamic>.from(json);
            for (final k in const [
              'balance', 'Balance', 'amount', 'Amount', 'total', 'Total', 'wallet_balance'
            ]) {
              final v = jsonToDouble(m[k]);
              if (v != null) return v;
            }
            // list ho to entries ke amounts ka sum (best effort)
            dynamic raw = m['data'] ?? m['Data'];
            if (raw is Map) raw = raw['data'] ?? raw['Data'] ?? raw['items'];
            if (raw is List) {
              double sum = 0;
              bool any = false;
              for (final e in raw) {
                if (e is Map) {
                  final em = Map<String, dynamic>.from(e);
                  final v = jsonToDouble(em['balance'] ??
                      em['amount'] ??
                      em['Balance'] ??
                      em['Amount']);
                  if (v != null) {
                    sum += v;
                    any = true;
                  }
                }
              }
              if (any) return sum;
            }
          }
          return null;
        },
      );
      if (res.isSuccess) {
        walletBalance = res.data ?? 0;
      }
    } catch (_) {}
    isLoadingWallet = false;
    update();
  }
}
