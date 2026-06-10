namespace DataLabellingSupportSystem.Api.DTOs.Requests.Auth;

public sealed record RegisterRequest(
    string FullName,
    string Email,
    string Password,
    string? PhoneNumber,
    string? IdentifyNumber,
    string? Gender,
    string? Address,
    DateOnly? DateOfBirth
);
