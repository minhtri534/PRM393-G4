namespace DataLabellingSupportSystem.Api.DTOs.Responses.Notifications;

public sealed record NotificationResponse(
    string Id,
    string Type,
    string Title,
    string? Body,
    string? ProjectId,
    string? ProjectName,
    string? ActorUserId,
    string? ActorFullName,
    string? RelatedEntityId,
    bool IsRead,
    DateTime CreatedAt);
