Map<String, dynamic> environment = {
  "serverConfig": {
    'apiUrl': 'https://alfurqan.ae/api/',
    'baseUrl': 'https://alfurqan.ae',
    'apiVersion': 'v1',
    'accessToken': '',
    'playStoreURL': 'https://play.google.com/store/apps/details?id=com.appName',
    'appStoreURL': 'https://apps.apple.com/us/app/itunes-connect/id8978990',
    'appDownloadURL': 'https://staging.carerockets.com/redirect/app-download',
  },
  "advanceConfig": {
    "defaultLanguage": "en",
    "defaultCurrency": {
      "symbol": "AED",
      "decimalDigits": 2,
      "symbolBeforeTheNumber": true,
      "currency": "AED",
      "currencyCode": "AED",
    },
    "isMultiLanguages": false,
  },
  "loginSetting": {
    "IsRequiredLogin": false,
    "showAppleLogin": false, // Nitin
    "showFacebook": false, // Nitin
    "showSMSLogin": false, // Nitin
    "showGoogleLogin": false, // Nitin
    "showPhoneNumberWhenRegister": true,
    "requirePhoneNumberWhenRegister": true,

    /// For Facebook login.
    "facebookAppId": "", // add your facebook app id
    "facebookLoginProtocolScheme":
        "", // add your facebook login protocol scheme
  },
};

/// Server kabhi kabhi image ka full URL deta hai (http se shuru),
/// kabhi kabhi sirf relative path (e.g. "media/62026/xxx.jpg").
/// Ye helper relative path ko hamesha baseUrl ke sath jod kar
/// ek full, directly-usable URL bana deta hai.
///
/// NOTE: agar image na dikhe to sambhavtah backend `/storage/` prefix
/// ke sath serve kar raha hai (Laravel ka common pattern) — us case me
/// neeche wali line me `${base}/${cleanPath}` ko
/// `${base}/storage/${cleanPath}` kar dena.
String buildMediaUrl(String? path) {
  if (path == null || path.isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;

  final String base = environment['serverConfig']['baseUrl'].toString();
  final String cleanPath = path.startsWith('/') ? path.substring(1) : path;
  return '$base/$cleanPath';
}
