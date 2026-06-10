namespace DataLabellingSupportSystem.Api.DTOs.Requests.Admin;

public sealed record ResetUserPasswordRequest(
    string NewPassword);

public sealed record AssignRolePermissionRequest(
    string RoleId);

public sealed record UpdateSystemSettingsRequest(
    bool? AiAssistEnabled,
    bool? DevSeedEnabled,
    string? StorageLocalRootPath);