class VerifyEmailOtpRequest {
  final String email;
  final String otpCode;

  VerifyEmailOtpRequest({
    required this.email,
    required this.otpCode,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'otpCode': otpCode,
      };
}
