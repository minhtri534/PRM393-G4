import 'user_profile.dart';

class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final UserProfile user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      user: UserProfile.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
        'user': user.toJson(),
      };
}
