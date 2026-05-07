class Role {
  final int id;
  final String roleName;

  Role({
    required this.id,
    required this.roleName,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['role_id'] ?? 0,
      roleName: json['role_name'] ?? '',
    );
  }
}

class SystemUser {
  final int userId;
  final String email;
  final String role;
  final String fullName;
  final bool isActive;
  final String createdAt;

  SystemUser({
    required this.userId,
    required this.email,
    required this.role,
    required this.fullName,
    required this.isActive,
    required this.createdAt,
  });

  factory SystemUser.fromJson(Map<String, dynamic> json) {
    return SystemUser(
      userId: json['user_id'] ?? 0,
      email: json['email'] ?? '',
      role: json['role'] ?? 'Unknown',
      fullName: json['full_name'] ?? 'Unknown',
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      createdAt: json['created_at'] != null ? json['created_at'].toString() : '',
    );
  }
}
