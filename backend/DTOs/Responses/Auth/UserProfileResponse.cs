namespace DataLabellingSupportSystem.Api.DTOs.Responses.Auth;

public sealed record UserProfileResponse(
    string Id,
    string FullName,
    string Email,
    string RoleId,
    string? RoleName,
    int Status
);
