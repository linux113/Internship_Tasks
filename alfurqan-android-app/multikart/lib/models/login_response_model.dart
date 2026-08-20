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
    return LoginResponseModel(
      id: json['id'] as int?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      name: json['name'] as String?,
      token: json['token'] as String?,
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
