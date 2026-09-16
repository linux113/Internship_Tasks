import 'package:multikart/controllers/home_product_controllers/cart_controller.dart';

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

  /// Abhi ACTIVE applied coupon code (storage se — cart/payment dono isi
  /// ko padhte hai). Card isi se "Applied/Remove" state banata hai (point 2).
  String get activeCode =>
      (storage.read('coupon_code')?.toString() ?? '').trim();

  bool isActive(String? code) =>
      code != null &&
      code.trim().isNotEmpty &&
      activeCode.toLowerCase() == code.trim().toLowerCase();

  /// Date string ko best-effort DateTime me (backend formats: ISO
  /// "2026-09-15T00:00:00", "15/09/2026", "15-09-2026"). Parse na ho to
  /// null — galti se block NAHI karna (server aakhiri authority hai).
  static DateTime? _parseDate(dynamic raw) {
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return null;
    final iso = DateTime.tryParse(s);
    if (iso != null) return iso;
    final first10 = s.length >= 10 ? s.substring(0, 10) : s;
    final iso2 = DateTime.tryParse(first10);
    if (iso2 != null) return iso2;
    final m = RegExp(r'^(\d{1,2})[/-](\d{1,2})[/-](\d{4})').firstMatch(first10);
    if (m != null) {
      final d = int.tryParse(m.group(1)!) ?? 0;
      final mo = int.tryParse(m.group(2)!) ?? 0;
      final y = int.tryParse(m.group(3)!) ?? 0;
      if (y > 1900 && mo >= 1 && mo <= 12 && d >= 1 && d <= 31) {
        return DateTime(y, mo, d);
      }
    }
    return null;
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
            // discount amount + type (terms/display dono ke liye)
            final amount = jsonToDouble(
                m['amount'] ?? m['Amount'] ?? m['discount'] ?? m['Discount']);
            final discType =
                jsonToString(m['type'] ?? m['Type'] ?? m['discount_type']) ??
                    '';
            if (desc.isEmpty && amount != null && amount > 0) {
              desc = discType.toLowerCase().contains('per')
                  ? 'Flat ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)}% off'
                  : 'Flat AED ${amount.toStringAsFixed(amount % 1 == 0 ? 0 : 2)} off';
            }
            // ---- TERMS (swagger Coupons schema keys) — point 4 ----
            final minSpend =
                jsonToDouble(m['min_spend'] ?? m['Min_Spend'] ?? m['minSpend']);
            final startRaw =
                m['start_date'] ?? m['Start_Date'] ?? m['startDate'];
            final endRaw = m['end_date'] ?? m['End_Date'] ?? m['endDate'];
            final startsAt = _parseDate(startRaw);
            final endsAt = _parseDate(endRaw);
            bool flag(dynamic v) =>
                v == true || v == 1 || v?.toString() == '1';
            final isFirstOrder = flag(m['is_first_order'] ??
                m['Is_First_Order'] ??
                m['first_order']);
            if (desc.isNotEmpty && endsAt != null) {
              final d =
                  '${endsAt.year.toString().padLeft(4, '0')}-${endsAt.month.toString().padLeft(2, '0')}-${endsAt.day.toString().padLeft(2, '0')}';
              desc = '$desc (${'validTill'.tr} $d)';
            }
            return CouponModel(
                code: code,
                title: title,
                description: desc,
                minSpend: (minSpend != null && minSpend > 0) ? minSpend : null,
                amount: amount,
                type: discType,
                startDate: startRaw?.toString(),
                endDate: endRaw?.toString(),
                startsAt: startsAt,
                endsAt: endsAt,
                isFirstOrder: isFirstOrder);
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

  /// Card par APPLY tap — 10/09 user design (deep fix): pehle sirf ek
  /// FAKE Hinglish toast aata tha ("Coupon X selected — checkout par apply
  /// hoga") aur AAGE KUCH NAHI hota tha (discount kabhi dikhta hi nahi).
  /// Ab TURANT real apply: CheckoutController zinda ho to wahi SAME
  /// CheckOut api coupon field ke saath DOBARA hit hoti hai, backend ka
  /// discounted amount payment ke rows/total me aa jata hai; phir is page
  /// se WAPAS (user ko checkout continue karne ke liye back nahi dabana
  /// pade). Checkout abhi tak nahi khula (cart page se aaya) to code save
  /// karo — payment khulte hi apne aap apply hoga.
  ///
  /// 15/09 additions (user points 1/4):
  ///  * point 4 — APPLY se PEHLE coupon ki TERMS client-side gate:
  ///    validity window (start/end), minimum order amount, first-order
  ///    only. Gate fail => code save hi NAHI hota + saaf toast.
  ///  * point 1 — cart wale flow me apply ke baad CartController ka
  ///    server-tax/coupon preview TURANT dobara chalao taaki cart ke
  ///    totals/discount rows bina "refresh" kiye turant badal jaye.
  Future<void> applyCode(String code) async {
    if (code.isEmpty) return;

    // ---- TERMS GATE (point 4) — sirf jab ye coupon list me ho (manual
    // bhi type kar sakta hai tab server preview hi decide karega) ----
    CouponModel? c;
    for (final e in couponList) {
      if ((e.code ?? '').trim().toLowerCase() == code.trim().toLowerCase()) {
        c = e;
        break;
      }
    }
    if (c != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      if (c.endsAt != null &&
          DateTime(c.endsAt!.year, c.endsAt!.month, c.endsAt!.day)
              .isBefore(today)) {
        _toast('couponExpired'.tr);
        return;
      }
      if (c.startsAt != null && c.startsAt!.isAfter(now)) {
        _toast('couponNotStarted'.tr);
        return;
      }
      // deep-review fix: server min_spend SUBTOTAL se toolta hai — Cart
      // zinda ho to uska RAW bag lo (arguments me final payable aata tha,
      // tax samet — borderline par galat gate). Payment se khule bina
      // arguments wale case me bhi ab gate KAAM karta hai.
      final bag = Get.isRegistered<CartController>()
          ? Get.find<CartController>().bagSubtotalRaw
          : (double.tryParse(totalAmount) ?? 0);
      if (c.minSpend != null && c.minSpend! > 0 && bag > 0) {
        if (bag + 0.001 < c.minSpend!) {
          _toast(
              '${'couponMinOrderMsg'.tr} AED ${c.minSpend!.toStringAsFixed(c.minSpend! % 1 == 0 ? 0 : 2)}');
          return;
        }
      }
      if (c.isFirstOrder &&
          Get.isRegistered<OrderHistoryController>() &&
          Get.find<OrderHistoryController>().orderHistoryList.isNotEmpty) {
        _toast('firstOrderCouponMsg'.tr);
        return;
      }
    }

    controller.text = code;
    await storage.write('coupon_code', code);
    update();
    if (Get.isRegistered<CheckoutController>()) {
      final ok = await Get.find<CheckoutController>().applyCoupon(code);
      if (ok) Get.back(); // payment page wapas — discounted totals dikhenge
    } else {
      // point 1 (15/09): cart se aaya user — apply karte hi cart ka server
      // preview DOBARA (coupon ke SAATH) chalao taaki wapas jaate hi
      // refreshed totals/discount dikhe ("refresh karna padta tha" bug).
      if (Get.isRegistered<CartController>()) {
        try {
          await Get.find<CartController>().fetchServerTax();
        } catch (_) {}
      }
      _toast('couponApplied'.tr);
      Get.back();
    }
  }

  /// REMOVE (point 2 — applied card ka button "Remove" banta hai): stored
  /// code saaf karo + checkout zinda ho to waha se bhi coupon hatao +
  /// cart ke totals wapas normal (fresh preview coupon KE BINA).
  Future<void> removeCode(String code) async {
    await storage.write('coupon_code', '');
    controller.text = '';
    if (Get.isRegistered<CheckoutController>()) {
      try {
        await Get.find<CheckoutController>().removeCoupon(silent: true);
      } catch (_) {}
    }
    if (Get.isRegistered<CartController>()) {
      try {
        await Get.find<CartController>().clearCoupon(silent: true);
        // fresh totals (coupon ke bina) — cart par turant sahi amount
        await Get.find<CartController>().fetchServerTax();
      } catch (_) {}
    }
    update();
    _toast('couponRemoved'.tr);
  }
}
