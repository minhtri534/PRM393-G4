class RegisterResponse {
  final String email;
  final String? devOtp;

  RegisterResponse({
    required this.email,
    this.devOtp,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      email: json['email']?.toString() ?? '',
      devOtp: json['devOtp']?.toString(),
    );
  }
}
