import '../../config.dart';
import '../../models/currency_api_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../utilities/currency_store.dart';

class CurrencyController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();
  dynamic currencyVal;

  /// Currency sheet isi list se banti hai — pehle static AppArray wali, phir
  /// API (GetAllCurrenciesFront) aa jane par real list se replace ho jati hai.
  List<dynamic> currencyList = [];

//currency change
  currencyChange(val, code) async {
    // App ki saari prices AED (base) me hai — isliye rate hamesha NAYI
    // currency ke `rateFromBase` se lo. (Pehle pichhle selected currency ke
    // map se lookup hota tha — doosri baar change karne par galat rate aata
    // tha, aur Map string ban kar save hone ki wajah se CRASH bhi hota tha.)
    currencyVal = val;
    appCtrl.priceSymbol = val['symbol'].toString();
    appCtrl.rateValue =
        double.tryParse((val['rateFromBase'] ?? 1).toString()) ?? 1.0;

    appCtrl.update();
    update();
    Get.forceAppUpdate();
    await CurrencyStore.save(
      code: code.toString(),
      symbol: appCtrl.priceSymbol,
      rate: appCtrl.rateValue,
    );
    Get.back();
  }

  @override
  void onReady() {
    currencyList = List.of(AppArray().currencyList);
    currencyVal = CurrencyStore.read() ?? AppArray().currencyList[0];
    update();
    fetchCurrencies();
    super.onReady();
  }

  /// Currency code ke hisaab se icon (jitne svg assets app me available hai).
  String _iconFor(String code) {
    switch (code.toUpperCase()) {
      case 'INR':
        return svgAssets.inr;
      default:
        return svgAssets.usd;
    }
  }

  /// Code ke hisaab se title (translation keys agar hain to wahi).
  String _titleFor(String code) {
    switch (code.toUpperCase()) {
      case 'AED':
        return 'UAE Dirham'.tr;
      case 'INR':
        return 'Indian rupee'.tr;
      case 'USD':
        return 'United States dollar'.tr;
      case 'EUR':
        return 'Euro'.tr;
      case 'GBP':
        return 'British pound'.tr;
      default:
        return code;
    }
  }

  /// Backend ke exchange_rate ko app ke multiplier (price * rate) me badlo.
  ///
  /// Backend ki current data quirks (2026-08):
  ///  - USD ka rate 3.65 hai (= 1 USD kitne AED ka hai, UAE peg) — yani
  ///    INVERTED; sahi multiplier 1/3.65 (~0.27) hota hai. Isliye USD (>1)
  ///    ko invert kar dete hai.
  ///  - GBP/EUR ke rate 0.01 hai — clear placeholder/galat data (65 AED ki
  ///    book £0.65 dikhne lagti). Aise toote rates wali currency list se
  ///    hata dete hai (backend pe rate theek karne par wo apne aap aa jayengi).
  double? _normalizeRate(CurrencyApiModel c) {
    double r = c.exchangeRate;
    if (r <= 0) return null;
    if (c.code.toUpperCase() == 'AED') return 1.0;
    if (c.code.toUpperCase() == 'USD' && r > 1) r = 1 / r;
    if (r < 0.1) return null; // toota hua placeholder rate
    return r;
  }

  /// GetAllCurrenciesFront se real currencies laao.
  Future<void> fetchCurrencies() async {
    try {
      final res = await ApiService().request<List<CurrencyApiModel>>(
        endpoint: ApiEndpoints.currencies,
        method: ApiMethod.get,
        fromJson: (json) => CurrencyApiModel.listFromJson(json),
      );
      if (!res.isSuccess || res.data == null || res.data!.isEmpty) return;

      final List<dynamic> built = [];
      for (final c in res.data!) {
        if (!c.status) continue;
        final rate = _normalizeRate(c);
        if (rate == null) continue;
        built.add({
          'icon': _iconFor(c.code),
          'title': _titleFor(c.code),
          'code': c.code,
          'symbol': c.symbol.isNotEmpty ? c.symbol : c.code,
          'rateFromBase': rate,
        });
      }
      if (built.isEmpty) return;

      // AED ko sabse upar rakho (base currency)
      built.sort((a, b) => (a['code'] == 'AED')
          ? -1
          : (b['code'] == 'AED')
              ? 1
              : a['code'].toString().compareTo(b['code'].toString()));

      currencyList = built;
      // saved currency ab bhi list me hai to usko selected rakho
      // (CurrencyStore.read() StoredCurrency OBJECT return karta hai, Map nahi)
      final saved = CurrencyStore.read();
      if (saved != null) {
        final match = built.where((e) => e['code'] == saved.code);
        currencyVal = match.isNotEmpty ? match.first : built.first;
      }
      update();
    } catch (_) {}
  }
}
