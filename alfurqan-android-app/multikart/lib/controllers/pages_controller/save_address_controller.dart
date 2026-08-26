import '../../config.dart';
import '../../models/location_model.dart';
import '../../utilities/address_store.dart';

/// Saved Address page — ab DEMO `deliveryDetailArray` nahi, real saved
/// addresses (AddAddress form se save hue, local store) dikhte hai.
/// (Server par bhi save hota hai via Location/AddAddress; list ke liye
/// Get-addresses api abhi backend se di nahi gayi, isliye local se dikhti hai.)
class SaveAddressController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());

  String value = "address";
  int selectRadio = 0;
  DeliveryDetailModel? deliveryDetail;

  /// Local store se saved addresses laa kar display model banao.
  void refreshList() {
    final List<AddressModel> saved = AddressStore.load();
    if (saved.isEmpty) {
      deliveryDetail = null;
    } else {
      deliveryDetail = DeliveryDetailModel(
          addressList:
              saved.map((e) => e.toAddressListDisplay()).toList());
    }
    update();
  }

  //select address
  selectAddress(val, index) {
    value = val.name!;
    selectRadio = index;
    update();
  }

  @override
  void onReady() {
    refreshList();
    super.onReady();
  }
}
