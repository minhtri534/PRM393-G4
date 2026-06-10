using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Admin;
using DataLabellingSupportSystem.Api.DTOs.Responses.Admin;

namespace DataLabellingSupportSystem.Api.Services.Admin;

public interface IAdminService
{
    Task<ServiceResponse<bool>> DisableUserAsync(string userId);
    Task<ServiceResponse<bool>> ResetUserPasswordAsync(string userId, ResetUserPasswordRequest request);
    Task<ServiceResponse<bool>> AssignRolePermissionAsync(string userId, AssignRolePermissionRequest request);

    Task<ServiceResponse<AdminSystemSettingsResponse>> GetSystemSettingsAsync();
    Task<ServiceResponse<AdminSystemSettingsResponse>> UpdateSystemSettingsAsync(UpdateSystemSettingsRequest request);
    Task<ServiceResponse<AdminSystemHealthResponse>> GetSystemHealthAsync();

    Task<ServiceResponse<List<AdminActivityLogResponse>>> GetActivityLogsAsync(int page, int pageSize, string? userId, string? action);
    Task<ServiceResponse<(byte[] Content, string FileName, string ContentType)>> ExportActivityLogsAsync(string format, string? userId, string? action);
}