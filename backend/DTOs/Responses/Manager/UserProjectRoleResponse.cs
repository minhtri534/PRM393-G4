namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record UserProjectRoleResponse(
    string UserId,
    string UserEmail,
    string ProjectId,
    string ProjectName,
    string RoleId,
    string RoleName
);
