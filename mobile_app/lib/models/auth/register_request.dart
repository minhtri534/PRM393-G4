class RegisterRequest {
  final String fullName;
  final String email;
  final String password;
  final String? phoneNumber;
  final String? identifyNumber;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;

  RegisterRequest({
    required this.fullName,
    required this.email,
    required this.password,
    this.phoneNumber,
    this.identifyNumber,
    this.gender,
    this.address,
    this.dateOfBirth,
  });

  Map<String, dynamic> toJson() => {
        'fullName': fullName,
        'email': email,
        'password': password,
        'phoneNumber': phoneNumber,
        'identifyNumber': identifyNumber,
        'gender': gender,
        'address': address,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
      };
}
