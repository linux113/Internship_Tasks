import '../../config.dart';
import '../../models/location_model.dart';
import '../../services/api_endpoints.dart';
import '../../services/api_service.dart';
import '../../utilities/address_store.dart';

/// Add Address — REAL backend (api/Location/AddAddress) ke sath.
///
/// - Country dropdown  <- GetAllCountryFront (states usi ke andar aate hai)
/// - State dropdown    <- selected country ki states (GetStatesFront fallback)
/// - City              <- TEXT input (web jaisa hi — user ne confirm kiya)
/// - Save              <- POST Location/AddAddress (LOGIN zaroori; guest ko
///                        pehle login page par bhejte hai) + local copy save.
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
    update();
    fetchCountries();
    super.onReady();
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

        // default: United Arab Emirates (store UAE ka hai) — na mile to pehla
        final uae = countries.indexWhere((e) =>
            (e.name ?? '').toLowerCase().contains('united arab emirates') ||
            (e.iso3 ?? '').toUpperCase() == 'ARE');
        onCountrySelected(uae >= 0 ? countries[uae].name ?? '' : countryNames.first);
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
    );

    bool savedOnServer = false;
    String message = 'Address added successfully';
    try {
      final res = await ApiService().request(
        endpoint: ApiEndpoints.addAddress,
        method: ApiMethod.post,
        data: address.toPostJson(),
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
      // response se naya address id mil jaye to use karo
      if (res.data is Map) {
        final map = Map<String, dynamic>.from(res.data as Map);
        final newId = map['id'];
        if (newId is num) address.id = newId.toInt();
      }
    } catch (_) {}

    if (!savedOnServer) {
      isSaving = false;
      update();
      socialLoginToast(message.isNotEmpty ? message : 'Could not save address. Please try again.');
      return;
    }

    // local copy save (Saved Address page yahi se dikhti hai)
    address.id ??= DateTime.now().millisecondsSinceEpoch;
    final list = AddressStore.load();
    list.add(address);
    await AddressStore.saveAll(list);

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
