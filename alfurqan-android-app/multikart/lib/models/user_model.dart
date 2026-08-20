class RoleModel {
  final int? id;
  final String? name;
  final String? guardName;

  RoleModel({this.id, this.name, this.guardName});

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      guardName: json['guard_name'] as String?,
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
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      roleName: json['role_name'] as String?,
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      phone: json['phone'] as String?,
      countryCode: json['country_code'] as String?,
      roleId: json['role_id'] as int?,
      status: json['status'] as bool?,
      createdAt: json['created_at'] as String?,
    );
  }

  /// GET user-list api paginated hai ({ data: { data: [...] } }),
  /// isliye ek helper de rahe hai jo directly List<UserModel> bana de.
  static List<UserModel> listFromJson(Map<String, dynamic> json) {
    final List list = json['data'] ?? [];
    return list.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
