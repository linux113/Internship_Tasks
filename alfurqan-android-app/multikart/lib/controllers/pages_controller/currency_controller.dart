
import '../../config.dart';
import '../../utilities/currency_store.dart';

class CurrencyController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();
  dynamic currencyVal;

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
    currencyVal = CurrencyStore.read() ?? AppArray().currencyList[0];
    super.onReady();
  }
}
