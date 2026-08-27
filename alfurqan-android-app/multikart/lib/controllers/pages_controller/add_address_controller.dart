import '../../config.dart';
import '../../models/location_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../utilities/address_store.dart';
import 'delivery_detail_controller.dart';
import 'save_address_controller.dart';

/// Add Address — REAL backend (api/Location/AddAddress) ke sath.
///
/// - Country dropdown  <- GetAllCountryFront (states usi ke andar aate hai)
/// - State dropdown    <- selected country ki states (GetStatesFront fallback)
/// - City              <- TEXT input (web jaisa hi — user ne confirm kiya)
/// - Save              <- POST Location/AddAddress (LOGIN zaroori; guest ko
///                        pehle login page par bhejte hai) + local copy save.
/// - EDIT mode         <- Saved Address page ke EDIT button se arguments me
///                        existing AddressModel aata hai: form prefill hota
///                        hai aur SAVE ab POST ki jagah Location/UpdateAddress
///                        (PUT, existing id ke sath) karta hai.
class AddAddressController extends GetxController {
  final appCtrl = Get.isRegistered<AppController>()
      ? Get.find<AppController>()
      : Get.put(AppController());
  final storage = LocalStorage();

  List addressType = [];
  int selectRadio = 0;
  bool isChecked = false;
  String value = "home";

  /// API se aaye countries (har country ke andar uski states bhi hoti hai)
  List<CountryModel> countries = [];

  /// Dropdowns ko string lists chahiye — selected country ki states se banti hai.
  List<String> countryNames = [];
  List<String> stateNames = [];

  /// Selected objects (POST body ke liye poora object chahiye backend ko)
  CountryModel? selectedCountry;
  StateModel? selectedState;

  bool isLoading = false; // countries aa rahi hai
  bool isSaving = false; // save button dab chuka hai

  /// EDIT mode — Saved Address page se aaya existing address (null = naya add)
  AddressModel? editing;

  //select address type (Home/Office/Other) — ye POST ka `title` banega
  selectAddressType(val, index) {
    value = val['title']!;
    selectRadio = index;
    update();
  }

  //text editing controllers
  TextEditingController txtFullName = TextEditingController();
  TextEditingController txtMobileNumber = TextEditingController();
  TextEditingController txtPinCode = TextEditingController();
  TextEditingController txtFlatHouseBuilding = TextEditingController();
  TextEditingController txtAreaColonyStreet = TextEditingController();
  TextEditingController txtLandmark = TextEditingController();
  TextEditingController txtTownCity = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  //focus node
  final FocusNode countryFocus = FocusNode();
  final FocusNode fullNameFocus = FocusNode();
  final FocusNode mobileNumberFocus = FocusNode();
  final FocusNode pinCodeFocus = FocusNode();
  final FocusNode flatHouseBuildingFocus = FocusNode();
  final FocusNode areaColonyStreetFocus = FocusNode();
  final FocusNode landmarkFocus = FocusNode();
  final FocusNode townCityFocus = FocusNode();
  final FocusNode stateProvinceRegionFocus = FocusNode();

  String stateSelectedValue = "Select state";
  String countrySelectedValue = "Select country";

  bool get _isLoggedIn => (storage.read(Session.isLogin) ?? false) == true;

  int get _userId {
    final raw = storage.read('id');
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  @override
  void onReady() {
    addressType = AppArray().addressType;
    // EDIT mode? Saved Address page ne arguments me existing address diya hai.
    final args = Get.arguments;
    if (args is Map && args['edit'] is AddressModel) {
      editing = args['edit'] as AddressModel;
      _applyEditPrefillText();
    }
    update();
    fetchCountries();
    super.onReady();
  }

  /// EDIT mode me text fields prefill karo (country/state dropdowns countries
  /// load hone ke baad fetchCountries me set hote hai).
  void _applyEditPrefillText() {
    final e = editing!;
    txtFullName.text = e.fullName ?? '';
    txtMobileNumber.text = e.phone ?? '';
    txtPinCode.text = e.pincode ?? '';
    txtFlatHouseBuilding.text = e.street ?? ''; // combined street wapas ek field me
    txtAreaColonyStreet.text = '';
    txtLandmark.text = e.landmark ?? '';
    txtTownCity.text = e.city ?? '';
    // title (Home/Office/Other) wapas select karo
    final t = (e.title ?? 'home').toLowerCase();
    value = t;
    final idx = addressType.indexWhere(
        (x) => (x['title'] ?? '').toString().toLowerCase() == t);
    if (idx >= 0) selectRadio = idx;
  }

  /// Countries aa jane ke baad edit-address ka country/state dropdown select.
  void _applyEditPrefillDropdowns() {
    final e = editing;
    if (e == null || countries.isEmpty) return;
    var idx = countries.indexWhere((c) =>
        (e.country?.id ?? 0) != 0 && c.id == e.country!.id);
    if (idx < 0) {
      idx = countries.indexWhere((c) =>
          (c.name ?? '').toLowerCase() ==
          (e.country?.name ?? '').toLowerCase());
    }
    if (idx < 0) return;
    onCountrySelected(countries[idx].name ?? '');
    // phir state (naam se match — stateName ya state object ka name)
    final sName =
        (e.state?.name ?? e.stateName ?? '').trim().toLowerCase();
    if (sName.isNotEmpty) {
      final match = stateNames.firstWhere(
          (s) => s.toLowerCase() == sName,
          orElse: () => '');
      if (match.isNotEmpty) onStateSelected(match);
    }
  }

  /// GetAllCountryFront — countries + unki states ek hi call me.
  Future<void> fetchCountries() async {
    isLoading = true;
    update();
    try {
      final res = await ApiService().request<List<CountryModel>>(
        endpoint: ApiEndpoints.countries,
        method: ApiMethod.get,
        fromJson: (json) => json is List
            ? json
                .where((e) => e is Map)
                .map((e) => CountryModel.fromJson(
                    Map<String, dynamic>.from(e as Map)))
                .toList()
            : <CountryModel>[],
      );
      if (res.isSuccess && res.data != null && res.data!.isNotEmpty) {
        countries = res.data!;
        countryNames =
            countries.map((e) => e.name ?? '').where((e) => e.isNotEmpty).toList();

        if (editing != null) {
          // EDIT mode: purane address ka country/state select karo
          _applyEditPrefillDropdowns();
        } else {
          // default: United Arab Emirates (store UAE ka hai) — na mile to pehla
          final uae = countries.indexWhere((e) =>
              (e.name ?? '').toLowerCase().contains('united arab emirates') ||
              (e.iso3 ?? '').toUpperCase() == 'ARE');
          onCountrySelected(
              uae >= 0 ? countries[uae].name ?? '' : countryNames.first);
        }
      }
    } catch (_) {}
    isLoading = false;
    update();
  }

  /// Country select — uski states load karo (country object ke andar hi hoti hai).
  void onCountrySelected(String countryName) {
    countrySelectedValue = countryName;
    selectedCountry = countries.firstWhere(
      (e) => e.name == countryName,
      orElse: () => countries.isNotEmpty ? countries.first : CountryModel(),
    );
    stateNames = (selectedCountry?.states ?? [])
        .map((e) => e.name ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
    if (stateNames.isNotEmpty) {
      onStateSelected(stateNames.first);
    } else {
      stateSelectedValue = "Select state";
      selectedState = null;
    }
    update();
  }

  /// State select.
  void onStateSelected(String stateName) {
    stateSelectedValue = stateName;
    final states = selectedCountry?.states ?? <StateModel>[];
    selectedState = states.firstWhere(
      (e) => e.name == stateName,
      orElse: () => states.isNotEmpty ? states.first : StateModel(),
    );
    update();
  }

  String? _validate() {
    if (txtFullName.text.trim().isEmpty) return 'Please enter full name';
    final phoneDigits =
        txtMobileNumber.text.trim().replaceAll(RegExp('[^0-9]'), '');
    if (phoneDigits.length < 7) return 'Please enter a valid mobile number';
    if (txtPinCode.text.trim().isEmpty) return 'Please enter pin code';
    if (txtFlatHouseBuilding.text.trim().isEmpty) {
      return 'Please enter flat / house no. / building';
    }
    if (txtAreaColonyStreet.text.trim().isEmpty) {
      return 'Please enter area / street';
    }
    if (selectedCountry == null || (selectedCountry?.id ?? 0) == 0) {
      return 'Please select country';
    }
    if (txtTownCity.text.trim().isEmpty) return 'Please enter town / city';
    if (stateNames.isNotEmpty && (selectedState?.id ?? 0) == 0) {
      return 'Please select state';
    }
    return null;
  }

  /// SAVE button — Location/AddAddress POST (login ke baad hi). Local copy bhi
  /// save hoti hai taaki Saved Address list me turant dikhe.
  Future<void> saveAddress() async {
    // login zaroori — user ne bola address login ke BAAD hi insert hona chahiye
    if (!_isLoggedIn) {
      socialLoginToast('Please login to add address');
      Get.toNamed(routeName.login);
      return;
    }

    final error = _validate();
    if (error != null) {
      socialLoginToast(error);
      return;
    }
    if (isSaving) return;
    isSaving = true;
    update();

    // street = flat + area + landmark (web form jaisa combined text)
    final streetParts = [
      txtFlatHouseBuilding.text.trim(),
      txtAreaColonyStreet.text.trim(),
      if (txtLandmark.text.trim().isNotEmpty) txtLandmark.text.trim(),
    ];

    final address = AddressModel(
      id: editing?.id, // edit me purani id hi rakhte hai
      title: value.isEmpty ? 'Home' : (value[0].toUpperCase() + value.substring(1)),
      fullName: txtFullName.text.trim(),
      street: streetParts.join(', '),
      landmark: txtLandmark.text.trim(),
      city: txtTownCity.text.trim(),
      stateName: stateSelectedValue == 'Select state' ? '' : stateSelectedValue,
      phone: txtMobileNumber.text.trim(),
      pincode: txtPinCode.text.trim(),
      userId: _userId,
      country: selectedCountry,
      state: selectedState,
      fromServer: editing?.fromServer ?? false,
    );

    // EDIT + server-saved ho to PUT UpdateAddress (existing id ke sath);
    // warna POST AddAddress (naya ya kabhi upload na hua local address).
    final bool isUpdate = editing?.fromServer == true;
    final endpoint =
        isUpdate ? ApiEndpoints.updateAddress : ApiEndpoints.addAddress;
    final method = isUpdate ? ApiMethod.put : ApiMethod.post;

    bool savedOnServer = false;
    String message =
        isUpdate ? 'Address updated successfully' : 'Address added successfully';
    // Backend ke Addresses table me CountryId/StateId SCALAR foreign keys hai.
    // Swagger AddressDto aur website ka working curl dono scalar
    // country_id/state_id bhejte hai — isliye variant 1 = scalar-only
    // (sabse reliable). AutoMapper nested-object error aaye to 2/3 try hote hai:
    //  1) state+country objects NULL, sirf scalar ids (FK fix)
    //  2) scalars + country object (state null — AutoMapper State error se bacho)
    //  3) scalars + state object + country object (purana curl-exact style)
    for (var variant = 1; variant <= 3 && !savedOnServer; variant++) {
      try {
        final res = await ApiService().request(
          endpoint: endpoint,
          method: method,
          data: address.toPostJson(
              variant: variant,
              isDefault: isChecked ? 1 : 0,
              serverId: isUpdate ? editing!.id : 0),
          fromJson: (json) => json,
        );
        savedOnServer = res.isSuccess;
        if (res.message.isNotEmpty) message = res.message;
        if (!savedOnServer && res.code == 401) {
          isSaving = false;
          update();
          socialLoginToast('Please login to add address');
          Get.toNamed(routeName.login);
          return;
        }
        if (savedOnServer && res.data is Map) {
          final map = Map<String, dynamic>.from(res.data as Map);
          final newId = map['id'] ?? map['Id'];
          if (newId is num && editing == null) address.id = newId.toInt();
        }
        // AutoMapper wali error aayi to agla variant try karo (loop chalta rahega)
      } catch (_) {}
    }

    if (!savedOnServer) {
      isSaving = false;
      update();
      // backend ke raw DB/.NET errors (FOREIGN KEY / type map) user ko mat
      // dikhao — friendly message do.
      String friendly = message;
      if (message.contains('FOREIGN KEY') || message.contains('INSERT statement')) {
        friendly =
            'Address could not be saved (server country data issue). Please try again or pick United Arab Emirates.';
      } else if (message.contains('type map') || message.contains('Mapping types')) {
        friendly =
            'Address could not be saved (server mapping issue). Please try again.';
      } else if (message.isEmpty) {
        friendly = 'Could not save address. Please try again.';
      }
      socialLoginToast(friendly);
      return;
    }

    // local copy save (Saved Address page yahi se dikhti hai)
    final list = AddressStore.load();
    if (editing != null) {
      // EDIT: purani entry hata kar updated daalo (id same rakhte hai)
      list.removeWhere((e) => e.id == editing!.id);
      address.fromServer = editing!.fromServer || isUpdate;
    } else {
      address.id ??= DateTime.now().millisecondsSinceEpoch;
      address.fromServer = true; // POST success = server par save ho gaya
    }
    list.add(address);
    await AddressStore.saveAll(list);

    // dono jagah ki lists refresh — Saved Address page + checkout Delivery page
    if (Get.isRegistered<SaveAddressController>()) {
      Get.find<SaveAddressController>().refreshList();
    }
    if (Get.isRegistered<DeliveryDetailController>()) {
      Get.find<DeliveryDetailController>().refreshList();
    }

    isSaving = false;
    update();
    socialLoginToast(message);
    Get.back();
  }

  // legacy socialLoginToast shortcut (login controller wala hi toast)
  void socialLoginToast(String msg) {
    final socialLoginCtrl = Get.isRegistered<SocialLoginController>()
        ? Get.find<SocialLoginController>()
        : Get.put(SocialLoginController());
    socialLoginCtrl.showToast(msg);
  }
}
