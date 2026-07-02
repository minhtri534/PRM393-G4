class UserSummaryModel {
  final String id;
  final String fullName;
  final String email;
  final String? roleName;

  UserSummaryModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.roleName,
  });

  factory UserSummaryModel.fromJson(Map<String, dynamic> json) =>
      UserSummaryModel(
        id: json['id']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        roleName: json['roleName']?.toString(),
      );
}
