namespace DataLabellingSupportSystem.Api.DTOs.Requests.Users;

public sealed record CreateUserRequest(
    string FullName,
    string Email,
    string Password,
    string RoleId,
    int Status = 0,
    string? PhoneNumber = null,
    string? IdentifyNumber = null,
    string? Gender = null,
    string? Address = null,
    DateOnly? DateOfBirth = null
);
