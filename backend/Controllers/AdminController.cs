using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Admin;
using DataLabellingSupportSystem.Api.DTOs.Responses.Admin;
using DataLabellingSupportSystem.Api.Services.Admin;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/admin")]
[Authorize(Roles = "Admin")]
public sealed class AdminController(IAdminService adminService) : ControllerBase
{
    [HttpPatch("users/{userId}/disable")]
    public async Task<ActionResult<ServiceResponse<bool>>> DisableUser([FromRoute] string userId)
    {
        var result = await adminService.DisableUserAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("users/{userId}/reset-password")]
    public async Task<ActionResult<ServiceResponse<bool>>> ResetUserPassword([FromRoute] string userId, [FromBody] ResetUserPasswordRequest request)
    {
        var result = await adminService.ResetUserPasswordAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("users/{userId}/role")]
    public async Task<ActionResult<ServiceResponse<bool>>> AssignRolePermission([FromRoute] string userId, [FromBody] AssignRolePermissionRequest request)
    {
        var result = await adminService.AssignRolePermissionAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("settings")]
    public async Task<ActionResult<ServiceResponse<AdminSystemSettingsResponse>>> GetSystemSettings()
    {
        var result = await adminService.GetSystemSettingsAsync();
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("settings")]
    public async Task<ActionResult<ServiceResponse<AdminSystemSettingsResponse>>> UpdateSystemSettings([FromBody] UpdateSystemSettingsRequest request)
    {
        var result = await adminService.UpdateSystemSettingsAsync(request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("health")]
    public async Task<ActionResult<ServiceResponse<AdminSystemHealthResponse>>> GetSystemHealth()
    {
        var result = await adminService.GetSystemHealthAsync();
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("activity-logs")]
    public async Task<ActionResult<ServiceResponse<List<AdminActivityLogResponse>>>> GetActivityLogs(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50,
        [FromQuery] string? userId = null,
        [FromQuery] string? action = null)
    {
        var result = await adminService.GetActivityLogsAsync(page, pageSize, userId, action);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("activity-logs/export")]
    public async Task<IActionResult> ExportActivityLogs(
        [FromQuery] string format = "csv",
        [FromQuery] string? userId = null,
        [FromQuery] string? action = null)
    {
        var result = await adminService.ExportActivityLogsAsync(format, userId, action);
        if (!result.IsSuccess)
        {
            if (result.Message == ErrorMessages.NotFound)
            {
                return NotFound(result);
            }

            return BadRequest(result);
        }

        return File(result.Data.Content, result.Data.ContentType, result.Data.FileName);
    }
}