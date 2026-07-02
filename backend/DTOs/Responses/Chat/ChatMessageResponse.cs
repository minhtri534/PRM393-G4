namespace DataLabellingSupportSystem.Api.DTOs.Responses.Chat;

public sealed record ChatMessageResponse(
    string Id,
    string ProjectId,
    string SenderUserId,
    string SenderFullName,
    string MessageType,
    string? Content,
    string? AttachmentFileName,
    string? AttachmentContentType,
    long? AttachmentSizeBytes,
    string? AttachmentUrl,
    DateTime CreatedAt
);
