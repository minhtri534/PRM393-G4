namespace DataLabellingSupportSystem.Api.DTOs.Requests.Users;

public sealed record UpdateOwnProfileRequest(
    string FullName,
    string Email,
    string? PhoneNumber,
    string? IdentifyNumber,
    string? Gender,
    string? Address,
    DateOnly? DateOfBirth
);
