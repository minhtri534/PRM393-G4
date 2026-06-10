namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record ActivityLogResponse(
    string Id,
    string UserId,
    string UserEmail,
    string Action,
    string TargetType,
    string TargetId,
    DateTime CreatedAt
);
