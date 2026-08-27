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

  /// true = ye address SERVER par saved hai (Location/AddAddress POST hua ya
  /// GetAllAddress se aaya). Edit/Delete ke waqt isi se decide hota hai ki
  /// server par UpdateAddress/DeleteAddress bhejna hai ya nahi.
  bool fromServer = false;

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
    this.fromServer = false,
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
      fromServer: json['fromServer'] == true,
    );
  }

  /// Location/GetAllAddress ka ek row — snake_case ya PascalCase dono chalega.
  factory AddressModel.fromServerJson(Map<String, dynamic> json) {
    CountryModel? country;
    final c = json['country'] ?? json['Country'];
    if (c is Map) {
      country = CountryModel.fromJson(Map<String, dynamic>.from(c));
    }
    StateModel? state;
    final s = json['state'] ?? json['State'];
    if (s is Map) {
      state = StateModel.fromJson(Map<String, dynamic>.from(s));
    }
    return AddressModel(
      id: jsonToInt(json['id'] ?? json['Id']),
      title: jsonToString(json['title'] ?? json['Title']),
      fullName: jsonToString(json['title'] ?? json['Title']),
      street: jsonToString(json['street'] ?? json['Street']),
      landmark: '',
      city: jsonToString(json['city'] ?? json['City']),
      stateName: jsonToString(json['stateName'] ?? json['StateName'] ?? state?.name),
      phone: jsonToString(json['phone'] ?? json['Phone']),
      pincode: jsonToString(json['pincode'] ?? json['Pincode']),
      userId: jsonToInt(json['user_id'] ?? json['userId'] ?? json['User_Id'] ?? json['UserId']),
      country: country,
      state: state,
      fromServer: true,
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
        'fromServer': fromServer,
        'country': country?.toLocalJson(),
        'stateLocal': state?.toLocalJson(),
      };

  /// Location/AddAddress POST body (user ke curl + swagger AddressDto ke mutabik).
  ///
  /// ROOT-CAUSE FIX (FOREIGN KEY "FK_Addresses_Core_Countries_CountryId"):
  /// backend ke `Addresses` table me CountryId / StateId SCALAR foreign-key
  /// columns hote hai. Swagger ka AddressDto bhi scalar `country_id`,
  /// `state_id`, `is_default`, `country_code` fields maangta hai — aur
  /// website ka working curl bhi yehi bhejta hai. Pehle hum sirf nested
  /// objects bhejte the, isliye CountryId=0 insert hota tha aur DB har baar
  /// FOREIGN KEY error deta tha. Ab scalar ids HAMESHA bhejte hai.
  ///
  /// [variant]:
  ///  1 = SCALAR-ONLY (web-exact): state/country objects null, sirf scalar
  ///      country_id + state_id (FK yahi se banta hai) — sabse reliable.
  ///  2 = scalars + country object (state null — AutoMapper "StateDto->State"
  ///      mapping error se bachne ke liye).
  ///  3 = scalars + state object + country object (purana curl-exact style).
  ///
  /// [serverId]: naya address = 0 (default). EDIT (Location/UpdateAddress PUT)
  /// ke liye existing address ki id pass karo.
  Map<String, dynamic> toPostJson({int variant = 1, int isDefault = 0, int? serverId}) {
    final body = <String, dynamic>{
      'id': serverId ?? 0,
      'city': city ?? '',
      'stateName': stateName ?? state?.name ?? '',
      'phone': int.tryParse((phone ?? '').replaceAll(RegExp('[^0-9]'), '')) ?? 0,
      'title': title ?? 'Home',
      'street': street ?? '',
      'pincode': pincode ?? '',
      'user_id': userId ?? 0,
      // ⭐ scalar FK fields — inke bina INSERT hamesha fail hota tha
      'state_id': state?.id ?? 0,
      'country_id': country?.id ?? 0,
      'is_default': isDefault,
      'country_code': country == null
          ? ''
          : ((country!.callingCode ?? '').isNotEmpty
              ? country!.callingCode!
              : (country!.iso2 ?? '')),
    };
    if (variant == 1) {
      body['state'] = null;
      body['country'] = null;
    } else if (variant == 2) {
      body['state'] = null;
      body['country'] = country?.toPostJson() ?? {};
    } else {
      body['state'] = state?.toPostJson(
              countryId: country?.id, countryName: country?.name) ??
          {'id': 0, 'name': stateName ?? '', 'countryId': country?.id ?? 0, 'country': country?.name ?? ''};
      body['country'] = country?.toPostJson() ?? {};
    }
    return body;
  }

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
