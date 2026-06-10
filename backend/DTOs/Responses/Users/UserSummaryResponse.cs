namespace DataLabellingSupportSystem.Api.DTOs.Responses.Users;

public sealed record UserSummaryResponse(
    string Id,
    string FullName,
    string Email,
    string? RoleName
);
