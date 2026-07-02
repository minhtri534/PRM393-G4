import 'package:mobile_app/models/manager/user_account_status.dart';

import '../../core/utils/value_parser.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? identifyNumber;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;
  final String roleId;
  final String? roleName;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.identifyNumber,
    this.gender,
    this.address,
    this.dateOfBirth,
    required this.roleId,
    this.roleName,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id']?.toString() ?? '',
    fullName: json['fullName']?.toString() ?? '',
    email: json['email']?.toString() ?? '',
    phoneNumber: json['phoneNumber']?.toString(),
    identifyNumber: json['identifyNumber']?.toString(),
    gender: json['gender']?.toString(),
    address: json['address']?.toString(),
    dateOfBirth: parseDateOnly(json['dateOfBirth']),
    roleId: json['roleId']?.toString() ?? '',
    roleName: json['roleName']?.toString(),
    status: parseInt(json['status']) ?? UserAccountStatus.active,
    createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
    updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? ''),
  );

  String get statusLabel => status == UserAccountStatus.pendingEmailVerification
      ? 'Pending verification'
      : 'Active';
}
