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
    super.onReady();
  }
}
