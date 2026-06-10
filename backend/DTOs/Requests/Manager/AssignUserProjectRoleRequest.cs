namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record AssignUserProjectRoleRequest(
    string UserId,
    string ProjectId,
    string RoleId
);
