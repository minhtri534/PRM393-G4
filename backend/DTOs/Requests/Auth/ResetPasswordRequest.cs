namespace DataLabellingSupportSystem.Api.DTOs.Requests.Auth;

public sealed record ResetPasswordRequest(string Email, string ResetToken, string NewPassword);
