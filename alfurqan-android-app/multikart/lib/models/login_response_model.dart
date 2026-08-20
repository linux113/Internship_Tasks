import 'json_parse_utils.dart';

class LoginResponseModel {
  final int? id;
  final String? email;
  final String? displayName;
  final String? name;
  final String? token;

  LoginResponseModel({
    this.id,
    this.email,
    this.displayName,
    this.name,
    this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    // Backend kuch responses me user object ke andar fields deta hai aur
    // token ko `token` / `access_token` / `authorisation.token` — kisi bhi
    // shape me bhej sakta hai. Sab shapes tolerate karo taaki login ke baad
    // token zaroor save ho.
    final Map<String, dynamic>? userNode =
        json['user'] is Map ? Map<String, dynamic>.from(json['user'] as Map) : null;
    final Map<String, dynamic>? authNode = json['authorisation'] is Map
        ? Map<String, dynamic>.from(json['authorisation'] as Map)
        : null;

    String? token = (json['token'] ??
            json['access_token'] ??
            authNode?['token'] ??
            authNode?['access_token'] ??
            userNode?['token'] ??
            userNode?['access_token'])
        ?.toString();

    return LoginResponseModel(
      id: jsonToInt(json['id'] ?? userNode?['id']),
      email: jsonToString(json['email'] ?? userNode?['email']),
      displayName: jsonToString(json['displayName'] ?? userNode?['displayName']),
      name: jsonToString(json['name'] ?? userNode?['name']),
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'displayName': displayName,
        'name': name,
        'token': token,
      };
}
