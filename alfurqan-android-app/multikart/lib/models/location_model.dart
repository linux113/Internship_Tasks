import 'address_list_model.dart';
import 'json_parse_utils.dart';

/// ---------------------------------------------------------------------------
/// Location models — GetAllCountryFront / GetStatesFront APIs ke liye.
///
/// Countries api (web/CoreFront/GetAllCountryFront) har country ke ANDAR hi
/// uski states bhejti hai (`state` list) — isliye country select karte hi
/// states ke liye alag call ki zaroorat nahi padti. (GetStatesFront bhi
/// available hai; fallback ke liye parse helper yahi hai.)
///
/// AddAddress (api/Location/AddAddress) ka body backend ko EXACT same shape
/// me country/state objects wapas chahiye — toPostJson() methods wahi banate
/// hai.
/// ---------------------------------------------------------------------------

class StateModel {
  final int? id;
  final String? name;
  final int? countryId;

  StateModel({this.id, this.name, this.countryId});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: jsonToInt(json['id'] ?? json['Id']),
      name: jsonToString(json['name'] ?? json['Name']),
      countryId: jsonToInt(json['country_id'] ?? json['countryId'] ?? json['CountryId'] ?? json['Country_Id']),
    );
  }

  /// Local storage (prefs) ke liye.
  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'name': name,
        'country_id': countryId,
      };

  /// AddAddress POST body ke liye (curl doc ke mutabik):
  /// { "id": 0, "name": "...", "countryId": 0, "country": "..." }
  Map<String, dynamic> toPostJson({int? countryId, String? countryName}) => {
        'id': id ?? 0,
        'name': name ?? '',
        'countryId': countryId ?? this.countryId ?? 0,
        'country': countryName ?? '',
      };
}

class CountryModel {
  final int? id;
  final String? name;
  final String? currency;
  final String? currencySymbol;
  final String? iso2;
  final String? iso3;
  final String? callingCode;
  final String? flag;
  final List<StateModel> states;

  CountryModel({
    this.id,
    this.name,
    this.currency,
    this.currencySymbol,
    this.iso2,
    this.iso3,
    this.callingCode,
    this.flag,
    this.states = const [],
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    final rawStates = json['state'] ?? json['states'];
    return CountryModel(
      id: jsonToInt(json['id'] ?? json['Id']),
      name: jsonToString(json['name'] ?? json['Name']),
      currency: jsonToString(json['currency'] ?? json['Currency']),
      currencySymbol: jsonToString(json['currency_symbol'] ?? json['currencySymbol']),
      iso2: jsonToString(json['iso_3166_2']),
      iso3: jsonToString(json['iso_3166_3']),
      callingCode: jsonToString(json['calling_code']),
      flag: jsonToString(json['flag']),
      states: rawStates is List
          ? rawStates
              .where((e) => e is Map)
              .map((e) => StateModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList()
          : const [],
    );
  }

  /// Local storage (prefs) ke liye.
  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'name': name,
        'currency': currency,
        'currency_symbol': currencySymbol,
        'iso_3166_2': iso2,
        'iso_3166_3': iso3,
        'calling_code': callingCode,
        'flag': flag,
        'state': states.map((e) => e.toLocalJson()).toList(),
      };

  /// AddAddress POST body ke liye — backend ka country object poora wapas:
  Map<String, dynamic> toPostJson() => {
        'id': id ?? 0,
        'name': name ?? '',
        'currency': currency ?? '',
        'currency_symbol': currencySymbol ?? '',
        'iso_3166_2': iso2 ?? '',
        'iso_3166_3': iso3 ?? '',
        'calling_code': callingCode ?? '',
        'flag': flag ?? '',
        'state': states
            .map((e) => {
                  'id': e.id ?? 0,
                  'name': e.name ?? '',
                  'country_id': (e.countryId ?? id ?? 0).toString(),
                })
            .toList(),
      };
}

/// Ek saved delivery/billing address.
/// Server pe POST (Location/AddAddress) bhi hota hai aur local prefs me bhi
/// rakhte hai (Get addresses api abhi di nahi gayi, isliye list local se
/// dikhti hai).
class AddressModel {
  int? id; // server id (mile to), warna local timestamp id
  String? title; // Home / Office / Other
  String? fullName;
  String? street; // flat/house + area/street join karke
  String? landmark;
  String? city;
  String? stateName;
  String? phone;
  String? pincode;
  int? userId;
  CountryModel? country;
  StateModel? state;

  AddressModel({
    this.id,
    this.title,
    this.fullName,
    this.street,
    this.landmark,
    this.city,
    this.stateName,
    this.phone,
    this.pincode,
    this.userId,
    this.country,
    this.state,
  });

  factory AddressModel.fromLocalJson(Map<String, dynamic> json) {
    return AddressModel(
      id: jsonToInt(json['id']),
      title: jsonToString(json['title']),
      fullName: jsonToString(json['fullName']),
      street: jsonToString(json['street']),
      landmark: jsonToString(json['landmark']),
      city: jsonToString(json['city']),
      stateName: jsonToString(json['stateName']),
      phone: jsonToString(json['phone']),
      pincode: jsonToString(json['pincode']),
      userId: jsonToInt(json['userId']),
      country: json['country'] is Map
          ? CountryModel.fromJson(Map<String, dynamic>.from(json['country'] as Map))
          : null,
      state: json['stateLocal'] is Map
          ? StateModel.fromJson(Map<String, dynamic>.from(json['stateLocal'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toLocalJson() => {
        'id': id,
        'title': title,
        'fullName': fullName,
        'street': street,
        'landmark': landmark,
        'city': city,
        'stateName': stateName,
        'phone': phone,
        'pincode': pincode,
        'userId': userId,
        'country': country?.toLocalJson(),
        'stateLocal': state?.toLocalJson(),
      };

  /// Location/AddAddress POST body (user ke curl ke mutabik).
  Map<String, dynamic> toPostJson() => {
        'id': 0,
        'city': city ?? '',
        'stateName': stateName ?? state?.name ?? '',
        'phone': int.tryParse((phone ?? '').replaceAll(RegExp('[^0-9]'), '')) ?? 0,
        'state': state?.toPostJson(
                countryId: country?.id, countryName: country?.name) ??
            {'id': 0, 'name': stateName ?? '', 'countryId': country?.id ?? 0, 'country': country?.name ?? ''},
        'title': title ?? 'Home',
        'street': street ?? '',
        'country': country?.toPostJson() ?? {},
        'pincode': pincode ?? '',
        'user_id': userId ?? 0,
        'state_id': state?.id ?? 0,
      };

  /// Saved-address list (SaveAddress page ke AddressList display model) ke liye.
  AddressList toAddressListDisplay() {
    return AddressList(
      name: (fullName ?? '').isNotEmpty ? fullName : (title ?? 'Home'),
      address: street,
      addressType: title,
      locality: landmark,
      state: stateName ?? state?.name,
      city: city,
      pinCode: pincode,
      phone: phone,
    );
  }
}
