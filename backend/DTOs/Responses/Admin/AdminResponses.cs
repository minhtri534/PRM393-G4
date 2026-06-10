namespace DataLabellingSupportSystem.Api.DTOs.Responses.Admin;

public sealed record AdminSystemSettingsResponse(
    bool AiAssistEnabled,
    bool DevSeedEnabled,
    string StorageLocalRootPath);

public sealed record AdminSystemHealthResponse(
    string Status,
    bool DatabaseConnected,
    long ManagedMemoryBytes,
    long WorkingSetBytes,
    DateTime ServerTimeUtc);

public sealed record AdminActivityLogResponse(
    string Id,
    string UserId,
    string UserEmail,
    string Action,
    string TargetType,
    string TargetId,
    DateTime CreatedAt);