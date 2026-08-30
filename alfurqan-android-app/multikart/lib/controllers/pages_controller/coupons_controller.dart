import '../../config.dart';
import '../../models/json_parse_utils.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';

/// COUPONS — pehle STATIC demo coupons (coupon_array se). Ab REAL
/// `GET api/Coupon/GetAllCoupons` se backend ke asli coupons.
/// Apply tap karne par code checkout ke liye storage me save ho jata hai.
class CouponsController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  TextEditingController controller = TextEditingController();
  String totalAmount = "0";

  List<CouponModel> couponList = [];
  bool isLoading = false;
  bool loadFailed = false;

  @override
  void onReady() {
    final args = Get.arguments;
    totalAmount = args?.toString() ?? "0";
    fetchCoupons();
    super.onReady();
  }

  void _toast(String msg) {
    final c = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    c.showToast(msg);
  }

  Future<void> fetchCoupons() async {
    isLoading = true;
    loadFailed = false;
    update();
    try {
      final res = await ApiService().request<List<CouponModel>>(
        endpoint: ApiEndpoints.getCoupons,
        method: ApiMethod.get,
        queryParams: {'page': 1, 'paginate': 50},
        fromJson: (json) {
          // lenient unwrap — {data:{data:[...]}} / {data:[...]} / [...]
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['coupons'];
          }
          if (raw is! List) return <CouponModel>[];
          return raw.where((e) => e is Map).map((e) {
            final m = Map<String, dynamic>.from(e as Map);
            final code = jsonToString(m['code'] ??
                    m['Code'] ??
                    m['coupon_code'] ??
                    m['Coupon_Code']) ??
                '';
            final title = jsonToString(
                    m['title'] ?? m['Title'] ?? m['name'] ?? m['Name']) ??
                '';
            String desc = jsonToString(m['description'] ??
                    m['Description'] ??
                    m['details'] ??
                    m['short_description']) ??
                '';
            // description na ho to discount/amount se bana do
            if (desc.isEmpty) {
              final disc = m['discount'] ?? m['Discount'] ?? m['amount'] ?? m['Amount'];
              final discType =
                  jsonToString(m['type'] ?? m['discount_type']) ?? '';
              if (disc != null && disc.toString().isNotEmpty) {
                desc = discType.toLowerCase().contains('per')
                    ? 'Flat $disc% off'
                    : 'Flat AED $disc off';
              }
            }
            final expired = m['end_date'] ?? m['End_Date'] ?? m['expiry'];
            if (desc.isNotEmpty && expired != null) {
              desc = '$desc (Valid till $expired)';
            }
            return CouponModel(code: code, title: title, description: desc);
          }).where((c) => (c.code ?? '').isNotEmpty).toList();
        },
      );
      if (res.isSuccess && res.data != null) {
        couponList = res.data!;
      } else {
        couponList = [];
        if (!res.isSuccess) loadFailed = true;
      }
    } catch (_) {
      loadFailed = true;
    }
    isLoading = false;
    update();
  }

  /// Card par APPLY tap — code textbox me bharo + checkout ke liye save.
  void applyCode(String code) {
    if (code.isEmpty) return;
    controller.text = code;
    storage.write('coupon_code', code);
    update();
    _toast('Coupon "$code" selected — checkout par apply hoga');
  }
}
