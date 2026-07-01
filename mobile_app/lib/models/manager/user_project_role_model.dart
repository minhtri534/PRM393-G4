class UserProjectRoleModel {
  final String userId;
  final String userEmail;
  final String projectId;
  final String? projectName;
  final String roleId;
  final String roleName;

  UserProjectRoleModel({
    required this.userId,
    required this.userEmail,
    required this.projectId,
    this.projectName,
    required this.roleId,
    required this.roleName,
  });

  factory UserProjectRoleModel.fromJson(Map<String, dynamic> json) =>
      UserProjectRoleModel(
        userId: json['userId']?.toString() ?? '',
        userEmail: json['userEmail']?.toString() ?? '',
        projectId: json['projectId']?.toString() ?? '',
        projectName: json['projectName']?.toString(),
        roleId: json['roleId']?.toString() ?? '',
        roleName: json['roleName']?.toString() ?? '',
      );
}