/// Backend kabhi-kabhi numbers ko STRING ke roop me bhej deta hai (jaise
/// "40.00" ya "50") aur booleans ko 0/1 me. Device par direct cast
/// (`as num?`) aise case me CRASH (TypeError) kar deta tha — aur ek product
/// fail hone par POORI product list parse fail ho jati thi (isliye phone par
/// home/shop demo fashion products dikhati thi, jabki categories sahi aati
/// thi). Ye helpers har value ko safe tarike se parse karte hai — koi bhi
/// shape aaye, kabhi throw nahi karenge.
library;

/// num ya numeric-string dono se double? banao.
double? jsonToDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString().trim());
}

/// num ya numeric-string dono se int? banao ("40.00" -> 40).
int? jsonToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  final s = v.toString().trim();
  return int.tryParse(s) ?? double.tryParse(s)?.toInt();
}

/// bool / 0|1 / "true"|"false" sab se bool? banao.
bool? jsonToBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().trim().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

/// null-safe String? (kuch bhi ho to string bana do).
String? jsonToString(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}
