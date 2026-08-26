import '../../config.dart';
import '../../models/location_model.dart';
import '../../utilities/address_store.dart';

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

  //select address
  selectAddress(val,index){
    value = val.name!;
    selectRadio = index;
    update();
  }

  @override
  void onReady() {
    refreshList();
    totalAmount = Get.arguments.toString();
    update();
    super.onReady();
  }
}
