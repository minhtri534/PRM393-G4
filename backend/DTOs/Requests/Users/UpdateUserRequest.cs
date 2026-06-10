namespace DataLabellingSupportSystem.Api.DTOs.Requests.Users;

public sealed record UpdateUserRequest(
    string FullName,
    string Email,
    string? Password,
    string RoleId,
    int Status,
    string? PhoneNumber,
    string? IdentifyNumber,
    string? Gender,
    string? Address,
    DateOnly? DateOfBirth
);
