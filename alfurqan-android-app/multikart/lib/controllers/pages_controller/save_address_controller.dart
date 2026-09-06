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

  void _toast(String msg) {
    final c = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    c.showToast(msg);
  }

  /// Fresh GetAllAddress me ye id ab bhi maujood hai? (delete VERIFY helper
  /// — cart-remove wala hi pattern; server hi sach hai).
  Future<bool> _serverAddressGone(int id) async {
    try {
      final res = await ApiService().request<bool>(
        endpoint: ApiEndpoints.getAllAddress,
        method: ApiMethod.get,
        fromJson: (json) {
          dynamic raw = json;
          for (var i = 0; i < 3 && raw is Map; i++) {
            raw = raw['data'] ?? raw['Data'] ?? raw['items'] ?? raw['Items'];
          }
          if (raw is! List) return true; // shape na mile: optimistic
          for (final e in raw) {
            if (e is Map) {
              final m = Map<String, dynamic>.from(e);
              final v =
                  m['id'] ?? m['Id'] ?? m['address_id'] ?? m['Address_Id'];
              if (int.tryParse(v?.toString() ?? '') == id) return false;
            }
          }
          return true;
        },
      );
      return res.isSuccess && (res.data ?? true);
    } catch (_) {
      return false; // verify hi na ho saka to "gone" mat maano
    }
  }

  /// REMOVE button — BULLETPROOF (user report 06/09: "removed dikhata hai
  /// par asal me hat-ta nahi — refresh par wapas aa jata hai").
  /// ROOT: purana code server delete ko fire & forget karta tha (result
  /// check hi nahi) aur local hata deta tha — server delete fail hone par
  /// agle GetAllAddress refresh me address WAPAS. Ab CART-REMOVE wala
  /// pattern: kai shapes try + har baar GetAllAddress se VERIFY; sirf
  /// server-se sach me gayab hone par hi local hatate hai aur success
  /// toast dikhate hai — warna address wapas laakar HONEST toast.
  Future<void> removeAddressAt(int index) async {
    if (index < 0 || index >= savedAddresses.length) return;
    final item = savedAddresses[index];
    final id = item.id;
    if (id == null) return;

    // Guest/local-only address — server call hi nahi chahiye
    if (!_isLoggedIn || !item.fromServer) {
      await AddressStore.remove(id);
      refreshThisAndDelivery();
      _toast('addressRemoved'.tr);
      return;
    }

    Future<bool> tryDelete() async {
      // swagger: DELETE /api/Location/DeleteAddress?id=<int32> —
      // LEKIN is backend ka har endpoint alag shape maangta raha hai
      // (cart/order me dekha) — isliye chain + VERIFY.
      final attempts = <Map<String, dynamic>>[
        {'m': ApiMethod.delete, 'q': {'id': id}, 'b': null},
        {'m': ApiMethod.delete, 'q': {'Id': id}, 'b': null},
        {'m': ApiMethod.delete, 'q': {'id': id.toString()}, 'b': null},
        {'m': ApiMethod.post, 'q': {'id': id}, 'b': const {}},
        {'m': ApiMethod.post, 'q': null, 'b': {'id': id}},
        {'m': ApiMethod.put, 'q': {'id': id}, 'b': const {}},
        {'m': ApiMethod.delete, 'q': null, 'b': {'Id': id}},
        {'m': ApiMethod.delete, 'q': null, 'b': {'id': id}},
      ];
      for (final a in attempts) {
        try {
          final res = await ApiService().request(
            endpoint: ApiEndpoints.deleteAddress,
            method: a['m'] as ApiMethod,
            queryParams: a['q'] == null
                ? null
                : Map<String, dynamic>.from(a['q'] as Map),
            data: a['b'],
            fromJson: (json) => json,
          );
          if (!res.isSuccess) continue;
          if (await _serverAddressGone(id)) return true;
        } catch (_) {}
      }
      // RAW-int body variants — ASP.NET [FromBody] int hota hai to
      // {id:12} bind NAHI hota, sirf raw 12 chalta hai (yeh shape hum pehle
      // kabhi nahi bhej sakte the kyunki ApiService.request map-body leta
      // hai — isliye dio direct).
      for (final usePost in [false, true]) {
        try {
          final res = usePost
              ? await ApiService()
                  .dio
                  .post(ApiEndpoints.deleteAddress, data: id)
              : await ApiService()
                  .dio
                  .delete(ApiEndpoints.deleteAddress, data: id);
          if (((res.statusCode ?? 0) ~/ 100) == 2 &&
              await _serverAddressGone(id)) {
            return true;
          }
        } catch (_) {}
      }
      // FULL-DTO body variants — is backend company ka pattern hai ki
      // PUT/POST ko POORA AddressDto body chahiye (AddAddress/UpdateAddress
      // dono aise hi chalte hai) — shayad DELETE bhi DTO body maangta ho.
      for (final usePost in [false, true]) {
        try {
          final res = await ApiService().request(
            endpoint: ApiEndpoints.deleteAddress,
            method: usePost ? ApiMethod.post : ApiMethod.delete,
            data: item.toPostJson(variant: 1, isDefault: 0, serverId: id),
            fromJson: (json) => json,
          );
          if (res.isSuccess && await _serverAddressGone(id)) return true;
        } catch (_) {}
      }
      // DEFAULT-ADDRESS guard — DB/server default (is_default=1) address
      // ko delete rok sakta hai: pehle UpdateAddress se is_default=0 karo
      // (PUT website se verified-chalta shape), phir swagger DELETE retry.
      try {
        await ApiService().request(
          endpoint: ApiEndpoints.updateAddress,
          method: ApiMethod.put,
          data: item.toPostJson(variant: 1, isDefault: 0, serverId: id),
          fromJson: (json) => json,
        );
        final res = await ApiService().request(
          endpoint: ApiEndpoints.deleteAddress,
          method: ApiMethod.delete,
          queryParams: {'id': id},
          fromJson: (json) => json,
        );
        if (res.isSuccess && await _serverAddressGone(id)) return true;
      } catch (_) {}
      // FINAL fallback — bulk endpoint (swagger: ids CSV string) — query +
      // body dono shapes.
      for (final a in <Map<String, dynamic>>[
        {'m': ApiMethod.delete, 'q': {'ids': id.toString()}, 'b': null},
        {'m': ApiMethod.delete, 'q': null, 'b': {'ids': id.toString()}},
        {'m': ApiMethod.post, 'q': null, 'b': {'ids': id.toString()}},
      ]) {
        try {
          final res = await ApiService().request(
            endpoint: ApiEndpoints.deleteAllAddress,
            method: a['m'] as ApiMethod,
            queryParams: a['q'] == null
                ? null
                : Map<String, dynamic>.from(a['q'] as Map),
            data: a['b'],
            fromJson: (json) => json,
          );
          if (res.isSuccess && await _serverAddressGone(id)) return true;
        } catch (_) {}
      }
      return false;
    }

    final ok = await tryDelete();
    if (ok) {
      await AddressStore.remove(id);
      // Delete hua address SELECTED tha to selection saaf karo — warna
      // checkout ghost address_id bhejta rahega.
      final sel = int.tryParse(
              storage.read('selected_address_id')?.toString() ?? '') ??
          -1;
      if (sel == id) await storage.write('selected_address_id', -1);
      refreshThisAndDelivery();
      _toast('addressRemoved'.tr);
    } else {
      // Server se sach me nahi hata (FK-block: order me use ho raha hai, ya
      // endpoint fail) — local fake-removal NAHI: list refresh karke
      // address wapas dikhao + HONEST toast.
      refreshThisAndDelivery();
      _toast('addressNotRemoved'.tr);
    }
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
