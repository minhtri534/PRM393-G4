class UserProfile {
  final String id;
  final String fullName;
  final String email;
  final String roleId;
  final String? roleName;
  final int status;

  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    required this.roleId,
    this.roleName,
    required this.status,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      roleId: json['roleId'] ?? '',
      roleName: json['roleName'],
      status: json['status'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'roleId': roleId,
        'roleName': roleName,
        'status': status,
      };
}
