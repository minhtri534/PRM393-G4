class ResendEmailVerificationRequest {
  final String email;

  ResendEmailVerificationRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}
