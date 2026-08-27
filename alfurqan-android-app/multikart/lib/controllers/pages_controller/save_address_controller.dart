import '../../config.dart';
import '../../models/location_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../utilities/address_store.dart';
import 'delivery_detail_controller.dart';

/// Saved Address page — real saved addresses (server GetAllAddress + local
/// store fallback), REMOVE aur EDIT dono working buttons ke sath.
///
/// - List: pehle local store se turant dikhta hai; logged-in ho to background
///   me Location/GetAllAddress (token se) se fresh list aakar replace ho jati
///   hai — website par save kiye addresses bhi yaha dikhte hai.
/// - REMOVE: local + (server par saved ho to) Location/DeleteAddress.
/// - EDIT: Add Address form hi prefill hokar khulta hai; save par
///   Location/UpdateAddress (PUT) hota hai.
class SaveAddressController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  String value = "address";
  int selectRadio = 0;
  DeliveryDetailModel? deliveryDetail;

  /// Pura address objects (edit/remove ke liye — display model me sab fields
  /// nahi hote isliye alag se rakhe hai; index display list se match karta hai)
  List<AddressModel> savedAddresses = [];

  bool get _isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  int get _userId {
    final raw = storage.read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  void _buildDisplay(List<AddressModel> list) {
    savedAddresses = list;
    if (list.isEmpty) {
      deliveryDetail = null;
    } else {
      deliveryDetail = DeliveryDetailModel(
          addressList: list.map((e) => e.toAddressListDisplay()).toList());
    }
    update();
  }

  /// Local store se turant dikhao; phir (logged-in ho to) server GetAllAddress
  /// se fresh list laao — server hi source-of-truth hai.
  Future<void> refreshList() async {
    _buildDisplay(AddressStore.load());

    if (!_isLoggedIn) return;
    try {
      final res = await ApiService().request<List<AddressModel>>(
        endpoint: ApiEndpoints.getAllAddress,
        method: ApiMethod.get,
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
          }
          if (raw is! List) return <AddressModel>[];
          return raw
              .where((e) => e is Map)
              .map((e) => AddressModel.fromServerJson(
                  Map<String, dynamic>.from(e as Map)))
              .toList();
        },
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        // sirf apne user ke addresses (agar row me user_id aata hai to filter)
        var serverList = res.data!;
        if (serverList.any((e) => (e.userId ?? 0) != 0)) {
          serverList =
              serverList.where((e) => (e.userId ?? 0) == _userId).toList();
        }
        if (serverList.isEmpty) return; // mera koi server address nahi — local hi dikhao

        // local-only (kabhi server par save na hue) addresses append karo
        final localOnly = AddressStore.load()
            .where((l) =>
                !l.fromServer &&
                !serverList.any((s) =>
                    s.street == l.street &&
                    s.pincode == l.pincode &&
                    s.phone == l.phone))
            .toList();
        final merged = [...serverList, ...localOnly];
        await AddressStore.saveAll(merged);
        _buildDisplay(merged);
      }
    } catch (_) {
      // network issue — local list hi rahegi
    }
  }

  //select address
  selectAddress(val, index) {
    value = val.name!;
    selectRadio = index;
    update();
  }

  /// REMOVE button — local se hatao + server par saved ho to DeleteAddress.
  /// Saved Address page aur checkout Delivery page dono refresh hote hai.
  Future<void> removeAddressAt(int index) async {
    if (index < 0 || index >= savedAddresses.length) return;
    final item = savedAddresses[index];

    // local turant
    if (item.id != null) await AddressStore.remove(item.id!);

    // server se bhi (best effort — sirf wahi jo server par saved hai)
    if (_isLoggedIn && item.fromServer && item.id != null) {
      try {
        await ApiService().request(
          endpoint: ApiEndpoints.deleteAddress,
          method: ApiMethod.delete,
          queryParams: {'id': item.id},
          fromJson: (json) => json,
        );
      } catch (_) {}
    }
    refreshThisAndDelivery();
  }

  /// EDIT button — Add Address form ko is address ke saath prefill karke kholo.
  Future<void> editAddressAt(int index) async {
    if (index < 0 || index >= savedAddresses.length) return;
    final item = savedAddresses[index];
    await Get.toNamed(routeName.addAddress, arguments: {'edit': item});
    // wapas aane par (save ya bina save) list refresh
    refreshThisAndDelivery();
  }

  /// Is page + checkout Delivery page dono ki lists refresh karo.
  void refreshThisAndDelivery() {
    refreshList();
    if (Get.isRegistered<DeliveryDetailController>()) {
      Get.find<DeliveryDetailController>().refreshList();
    }
  }

  @override
  void onReady() {
    refreshList();
    super.onReady();
  }
}
