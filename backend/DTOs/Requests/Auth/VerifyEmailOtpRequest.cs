namespace DataLabellingSupportSystem.Api.DTOs.Requests.Auth;

public sealed record VerifyEmailOtpRequest(string Email, string OtpCode);
