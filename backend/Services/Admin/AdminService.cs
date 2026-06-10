using System.Diagnostics;
using System.Text;
using System.Text.Json;
using System.Text.Json.Nodes;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Admin;
using DataLabellingSupportSystem.Api.DTOs.Responses.Admin;
using DataLabellingSupportSystem.Api.Services.Auth;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Admin;

public sealed class AdminService(
    AppDbContext dbContext,
    IPasswordHasher passwordHasher,
    IHostEnvironment hostEnvironment,
    IConfiguration configuration) : IAdminService
{
    public async Task<ServiceResponse<bool>> DisableUserAsync(string userId)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        user.Status = 1;
        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "User disabled");
    }

    public async Task<ServiceResponse<bool>> ResetUserPasswordAsync(string userId, ResetUserPasswordRequest request)
    {
        var id = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid user", ["User id is required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        user.PasswordHash = passwordHasher.Hash(request.NewPassword);
        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Password reset");
    }

    public async Task<ServiceResponse<bool>> AssignRolePermissionAsync(string userId, AssignRolePermissionRequest request)
    {
        var id = (userId ?? string.Empty).Trim();
        var roleId = (request.RoleId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(id) || string.IsNullOrWhiteSpace(roleId))
        {
            return ServiceResponse<bool>.Failure("Invalid request", ["User id and role id are required"]);
        }

        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == id);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var roleExists = await dbContext.Roles.AsNoTracking().AnyAsync(x => x.Id == roleId);
        if (!roleExists)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Role not found"]);
        }

        user.RoleId = roleId;
        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Role assigned");
    }

    public Task<ServiceResponse<AdminSystemSettingsResponse>> GetSystemSettingsAsync()
    {
        var aiAssistEnabled = bool.TryParse(configuration["AiAssist:Enabled"], out var ai) && ai;
        var devSeedEnabled = bool.TryParse(configuration["DevSeed:Enabled"], out var ds) && ds;
        var localRoot = configuration["Storage:LocalRootPath"] ?? "storage";

        var response = new AdminSystemSettingsResponse(aiAssistEnabled, devSeedEnabled, localRoot);
        return Task.FromResult(ServiceResponse<AdminSystemSettingsResponse>.Success(response, "OK"));
    }

    public async Task<ServiceResponse<AdminSystemSettingsResponse>> UpdateSystemSettingsAsync(UpdateSystemSettingsRequest request)
    {
        var settingsPath = Path.Combine(hostEnvironment.ContentRootPath, "appsettings.Development.json");
        if (!File.Exists(settingsPath))
        {
            return ServiceResponse<AdminSystemSettingsResponse>.Failure(ErrorMessages.NotFound, ["appsettings.Development.json not found"]);
        }

        var json = await File.ReadAllTextAsync(settingsPath);
        var root = JsonNode.Parse(json) as JsonObject;
        if (root is null)
        {
            return ServiceResponse<AdminSystemSettingsResponse>.Failure("Invalid settings", ["Cannot parse settings file"]);
        }

        SetNestedValue(root, "AiAssist", "Enabled", request.AiAssistEnabled);
        SetNestedValue(root, "DevSeed", "Enabled", request.DevSeedEnabled);
        if (!string.IsNullOrWhiteSpace(request.StorageLocalRootPath))
        {
            SetNestedValue(root, "Storage", "LocalRootPath", request.StorageLocalRootPath.Trim());
        }

        var updatedJson = root.ToJsonString(new JsonSerializerOptions { WriteIndented = true });
        await File.WriteAllTextAsync(settingsPath, updatedJson);

        var aiAssistEnabled = request.AiAssistEnabled ?? (bool.TryParse(configuration["AiAssist:Enabled"], out var ai) && ai);
        var devSeedEnabled = request.DevSeedEnabled ?? (bool.TryParse(configuration["DevSeed:Enabled"], out var ds) && ds);
        var localRoot = request.StorageLocalRootPath ?? configuration["Storage:LocalRootPath"] ?? "storage";

        return ServiceResponse<AdminSystemSettingsResponse>.Success(
            new AdminSystemSettingsResponse(aiAssistEnabled, devSeedEnabled, localRoot),
            "Updated. Restart API to apply all changes");
    }

    public async Task<ServiceResponse<AdminSystemHealthResponse>> GetSystemHealthAsync()
    {
        var canConnect = await dbContext.Database.CanConnectAsync();
        var process = Process.GetCurrentProcess();

        var response = new AdminSystemHealthResponse(
            Status: canConnect ? "Healthy" : "Degraded",
            DatabaseConnected: canConnect,
            ManagedMemoryBytes: GC.GetTotalMemory(forceFullCollection: false),
            WorkingSetBytes: process.WorkingSet64,
            ServerTimeUtc: DateTime.UtcNow);

        return ServiceResponse<AdminSystemHealthResponse>.Success(response, "OK");
    }

    public async Task<ServiceResponse<List<AdminActivityLogResponse>>> GetActivityLogsAsync(int page, int pageSize, string? userId, string? action)
    {
        var uid = (userId ?? string.Empty).Trim();
        var act = (action ?? string.Empty).Trim();

        var query = dbContext.ActivityLogs.AsNoTracking().AsQueryable();
        if (!string.IsNullOrWhiteSpace(uid))
        {
            query = query.Where(x => x.UserId == uid);
        }

        if (!string.IsNullOrWhiteSpace(act))
        {
            query = query.Where(x => x.Action.Contains(act));
        }

        var safePage = Math.Max(page, 1);
        var safeSize = Math.Clamp(pageSize, 1, 200);
        var skip = (safePage - 1) * safeSize;

        var items = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip(skip)
            .Take(safeSize)
            .Select(x => new AdminActivityLogResponse(
                x.Id,
                x.UserId,
                x.User != null ? x.User.Email : string.Empty,
                x.Action,
                x.TargetType,
                x.TargetId,
                x.CreatedAt))
            .ToListAsync();

        return ServiceResponse<List<AdminActivityLogResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<(byte[] Content, string FileName, string ContentType)>> ExportActivityLogsAsync(string format, string? userId, string? action)
    {
        var normalizedFormat = (format ?? "csv").Trim().ToLowerInvariant();
        if (normalizedFormat != "csv" && normalizedFormat != "json")
        {
            return ServiceResponse<(byte[] Content, string FileName, string ContentType)>.Failure("Invalid format", ["Supported formats: csv, json"]);
        }

        var logsResult = await GetActivityLogsAsync(1, 10000, userId, action);
        if (!logsResult.IsSuccess || logsResult.Data is null)
        {
            return ServiceResponse<(byte[] Content, string FileName, string ContentType)>.Failure(logsResult.Message, logsResult.Errors);
        }

        if (normalizedFormat == "json")
        {
            var json = JsonSerializer.Serialize(logsResult.Data, new JsonSerializerOptions { WriteIndented = true });
            return ServiceResponse<(byte[] Content, string FileName, string ContentType)>.Success(
                (Encoding.UTF8.GetBytes(json), $"activity-logs-{DateTime.UtcNow:yyyyMMddHHmmss}.json", "application/json"),
                "OK");
        }

        var sb = new StringBuilder();
        sb.AppendLine("Id,UserId,UserEmail,Action,TargetType,TargetId,CreatedAt");
        foreach (var item in logsResult.Data)
        {
            sb.AppendLine(string.Join(",",
                Csv(item.Id),
                Csv(item.UserId),
                Csv(item.UserEmail),
                Csv(item.Action),
                Csv(item.TargetType),
                Csv(item.TargetId),
                Csv(item.CreatedAt.ToString("O"))));
        }

        return ServiceResponse<(byte[] Content, string FileName, string ContentType)>.Success(
            (Encoding.UTF8.GetBytes(sb.ToString()), $"activity-logs-{DateTime.UtcNow:yyyyMMddHHmmss}.csv", "text/csv"),
            "OK");
    }

    private static void SetNestedValue(JsonObject root, string sectionName, string key, object? value)
    {
        var section = root[sectionName] as JsonObject;
        if (section is null)
        {
            section = new JsonObject();
            root[sectionName] = section;
        }

        section[key] = value is null ? null : JsonValue.Create(value);
    }

    private static string Csv(string value)
    {
        var escaped = (value ?? string.Empty).Replace("\"", "\"\"");
        return $"\"{escaped}\"";
    }
}