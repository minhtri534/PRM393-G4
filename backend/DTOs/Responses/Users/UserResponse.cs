namespace DataLabellingSupportSystem.Api.DTOs.Responses.Users;

public sealed record UserResponse(
    string Id,
    string FullName,
    string Email,
    string? PhoneNumber,
    string? IdentifyNumber,
    string? Gender,
    string? Address,
    DateOnly? DateOfBirth,
    string RoleId,
    string? RoleName,
    int Status,
    DateTime CreatedAt,
    DateTime UpdatedAt
);
