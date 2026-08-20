import 'json_parse_utils.dart';

class RoleModel {
  final int? id;
  final String? name;
  final String? guardName;

  RoleModel({this.id, this.name, this.guardName});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name']),
      guardName: jsonToString(json['guard_name']),
    );
  }
}

/// Register (AddUser) api aur user-list api dono isi shape ka
/// object dete hai, isliye ek hi model use ho raha hai.
class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? roleName;
  final RoleModel? role;
  final String? phone;
  final String? countryCode;
  final int? roleId;
  final bool? status;
  final String? createdAt;

  UserModel({
    this.id,
    this.name,
    this.email,
    this.roleName,
    this.role,
    this.phone,
    this.countryCode,
    this.roleId,
    this.status,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: jsonToInt(json['id']),
      name: jsonToString(json['name']),
      email: jsonToString(json['email']),
      roleName: jsonToString(json['role_name']),
      role: json['role'] is Map
          ? RoleModel.fromJson(Map<String, dynamic>.from(json['role'] as Map))
          : null,
      phone: jsonToString(json['phone']),
      countryCode: jsonToString(json['country_code']),
      roleId: jsonToInt(json['role_id']),
      status: jsonToBool(json['status']),
      createdAt: jsonToString(json['created_at']),
    );
  }

  /// GET user-list api paginated hai ({ data: { data: [...] } }),
  /// isliye ek helper de rahe hai jo directly List<UserModel> bana de.
  static List<UserModel> listFromJson(Map<String, dynamic> json) {
    final List list = json['data'] ?? [];
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
