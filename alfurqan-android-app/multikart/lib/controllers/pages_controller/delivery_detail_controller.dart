import '../../config.dart';
import '../../models/location_model.dart';
import '../../utilities/address_store.dart';
import '../home_product_controllers/cart_controller.dart';

class DeliveryDetailController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String value = "address";
  int selectRadio = 0;
  DeliveryDetailModel? deliveryDetail;
  String totalAmount ="0";
  bool isLoadingAddresses = false;

  /// Checkout address step — user ke REAL saved addresses (local store se,
  /// server par Location/AddAddress se save hue). Koi nahi to khaali rahega
  /// (demo addresses nahi) — user AddNewAddress se naya daal sakta hai.
  void refreshList() {
    final List<AddressModel> saved = AddressStore.load();
    deliveryDetail = saved.isEmpty
        ? null
        : DeliveryDetailModel(
            addressList: saved.map((e) => e.toAddressListDisplay()).toList());
    update();
  }

  /// 08/09 DEEP-fix: purana code sirf LOCAL store padhta tha — fresh
  /// install / storage-clear par checkout ke delivery step par addresses
  /// KABHI nahi aate the (blank page + sirf Add New Address), chahe server
  /// par pade ho. Ab server GetAllAddress se merge lao (shared sync) +
  /// loader dikhao jab tak list nahi ban-ti.
  Future<void> syncFromServer() async {
    final loggedIn = (storage.read(Session.isLogin) ?? false) == true;
    if (!loggedIn) return;
    isLoadingAddresses = true;
    update();
    try {
      await AddressStore.syncFromServer();
    } catch (_) {}
    isLoadingAddresses = false;
    refreshList();
  }

  //select address — checkout ke liye selected address ka ID bhi save kar
  // do (OrderPlace ko shipping_address_id chahiye hota hai)
  final storage = LocalStorage();

  selectAddress(val, index) {
    value = val.name!;
    selectRadio = index;
    update();
    try {
      final list = AddressStore.load();
      if (index >= 0 && index < list.length) {
        storage.write('selected_address_id', list[index].id);
      }
    } catch (_) {}
    // 17/09 DEEP FIX (Lalit ke screenshots): DELIVERY/SHIPPING charge
    // ADDRESS ke hisaab se badalta hai — pehla address UAE-local AED0.00
    // (Na, 7664), usne jo SELECT kiya (Algeria +213, 49494) uska AED20.00.
    // Purana code sirf ID save karta tha — preview PURANE address ka rehta
    // tha, isliye step-2/cart sheet par "Delivery AED0.00" aata tha jabki
    // payment par AED20.00 dikhta tha (user ke liye confusing). Ab select
    // karte hi CheckOut preview NAYE address se dobara aata hai —
    // Delivery/Tax/Total turant sahi.
    try {
      if (Get.isRegistered<CartController>()) {
        // 17/09 (Lalit — "har address par delivery same"): preview ka
        // result USER KO DIKHNA chahiye — pehle silently refresh hota tha
        // aur charge same nikla to koi feedback nahi. Ab charge BADLA to
        // turant toast: server ne delivery charge update kar diya. (Dono
        // addresses ka charge same ho to server ka jawab hi same hai —
        // shipping charge server ke zones se aata hai, app invent nahi
        // karti.)
        final cc = Get.find<CartController>();
        final before = cc.serverShippingValue;
        cc.fetchServerTax().then((ok) {
          try {
            final after = cc.serverShippingValue;
            if (ok && (after - before).abs() > 0.004) {
              snackBar('deliveryChargeUpdated'.tr);
            }
          } catch (_) {}
        });
      }
    } catch (_) {}
  }

  @override
  void onReady() {
    refreshList();
    // FIX: arguments null/zero ho to LIVE cart ka total use karo — sirf
    // arguments chain par bharosa karne se kabhi-kabhi galat/0 total pahunch
    // jata tha (single source of truth = server cart).
    totalAmount = Get.arguments?.toString() ?? '0';
    if ((double.tryParse(totalAmount) ?? 0) <= 0 &&
        Get.isRegistered<CartController>()) {
      final live = Get.find<CartController>().cartModelList?.totalAmount;
      if ((live ?? 0) > 0) totalAmount = live!.toStringAsFixed(2);
    }
    update();
    // server se addresses lao (blank page fix + loader)
    syncFromServer();
    super.onReady();
  }
}
