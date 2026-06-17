namespace DataLabellingSupportSystem.Api.DTOs.Responses.Auth;

public sealed record RegisterResponse(
    string Email,
    string? DevOtp = null);
