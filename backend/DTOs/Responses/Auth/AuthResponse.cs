namespace DataLabellingSupportSystem.Api.DTOs.Responses.Auth;

public sealed record AuthResponse(
    string AccessToken,
    string RefreshToken,
    UserProfileResponse User
);
