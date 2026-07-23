using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Chat;
using DataLabellingSupportSystem.Api.DTOs.Responses.Chat;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.Notifications;
using DataLabellingSupportSystem.Api.Services.Projects;
using DataLabellingSupportSystem.Api.Services.Storage;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Chat;

public interface IChatService
{
    Task<ServiceResponse<List<ChatMessageResponse>>> GetMessagesAsync(string actorUserId, string projectId, int page, int pageSize);
    Task<ServiceResponse<ChatMessageResponse>> SendTextMessageAsync(string actorUserId, string projectId, SendChatMessageRequest request);
    Task<ServiceResponse<ChatMessageResponse>> SendAttachmentMessageAsync(
        string actorUserId,
        string projectId,
        IFormFile file,
        string? caption,
        CancellationToken cancellationToken);
    Task<ServiceResponse<(Stream Stream, string ContentType, string FileName)?>> OpenAttachmentAsync(
        string actorUserId,
        string messageId,
        CancellationToken cancellationToken);
}

public sealed class ChatService(
    AppDbContext dbContext,
    IProjectMembershipService projectMembershipService,
    IStorageService storageService,
    INotificationService notificationService) : IChatService
{
    private const long MaxAttachmentBytes = 10 * 1024 * 1024;

    public async Task<ServiceResponse<List<ChatMessageResponse>>> GetMessagesAsync(
        string actorUserId,
        string projectId,
        int page,
        int pageSize)
    {
        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        var access = await projectMembershipService.EnsureProjectAccessAsync(actorUserId, normalizedProjectId);
        if (access is not null)
        {
            return ServiceResponse<List<ChatMessageResponse>>.Failure(access.Message, access.Errors);
        }

        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);
        var skip = (safePage - 1) * safePageSize;

        var messages = await dbContext.ProjectChatMessages
            .AsNoTracking()
            .Where(x => x.ProjectId == normalizedProjectId)
            .OrderByDescending(x => x.CreatedAt)
            .Skip(skip)
            .Take(safePageSize)
            .Select(x => new
            {
                x.Id,
                x.ProjectId,
                x.SenderUserId,
                SenderFullName = x.SenderUser != null ? x.SenderUser.FullName : "Unknown",
                x.MessageType,
                x.Content,
                x.AttachmentFileName,
                x.AttachmentContentType,
                x.AttachmentSizeBytes,
                x.AttachmentObjectKey,
                x.CreatedAt
            })
            .ToListAsync();

        var items = messages
            .Select(x => MapMessage(
                x.Id,
                x.ProjectId,
                x.SenderUserId,
                x.SenderFullName,
                x.MessageType,
                x.Content,
                x.AttachmentFileName,
                x.AttachmentContentType,
                x.AttachmentSizeBytes,
                x.AttachmentObjectKey,
                x.CreatedAt))
            .OrderBy(x => x.CreatedAt)
            .ToList();

        return ServiceResponse<List<ChatMessageResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<ChatMessageResponse>> SendTextMessageAsync(
        string actorUserId,
        string projectId,
        SendChatMessageRequest request)
    {
        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        var content = (request.Content ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(content))
        {
            return ServiceResponse<ChatMessageResponse>.Failure("Invalid message", ["Message content is required"]);
        }

        if (content.Length > 2000)
        {
            return ServiceResponse<ChatMessageResponse>.Failure("Invalid message", ["Message content is too long"]);
        }

        var access = await projectMembershipService.EnsureProjectAccessAsync(actorUserId, normalizedProjectId);
        if (access is not null)
        {
            return ServiceResponse<ChatMessageResponse>.Failure(access.Message, access.Errors);
        }

        var sender = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => new { x.Id, x.FullName })
            .FirstOrDefaultAsync();

        if (sender is null)
        {
            return ServiceResponse<ChatMessageResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var entity = new ProjectChatMessage
        {
            ProjectId = normalizedProjectId,
            SenderUserId = sender.Id,
            MessageType = "text",
            Content = content,
            CreatedAt = DlssTime.VietnamNow
        };

        dbContext.ProjectChatMessages.Add(entity);
        await dbContext.SaveChangesAsync();

        var response = MapMessage(
            entity.Id,
            entity.ProjectId,
            entity.SenderUserId,
            sender.FullName,
            entity.MessageType,
            entity.Content,
            null,
            null,
            null,
            null,
            entity.CreatedAt);

        await NotifyChatRecipientsAsync(actorUserId, sender.FullName, normalizedProjectId, entity.Id, content);

        return ServiceResponse<ChatMessageResponse>.Success(response, "Sent");
    }

    public async Task<ServiceResponse<ChatMessageResponse>> SendAttachmentMessageAsync(
        string actorUserId,
        string projectId,
        IFormFile file,
        string? caption,
        CancellationToken cancellationToken)
    {
        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        var access = await projectMembershipService.EnsureProjectAccessAsync(actorUserId, normalizedProjectId);
        if (access is not null)
        {
            return ServiceResponse<ChatMessageResponse>.Failure(access.Message, access.Errors);
        }

        if (file.Length <= 0)
        {
            return ServiceResponse<ChatMessageResponse>.Failure("Invalid file", ["Uploaded file must not be empty"]);
        }

        if (file.Length > MaxAttachmentBytes)
        {
            return ServiceResponse<ChatMessageResponse>.Failure("Invalid file", ["File size must be 10 MB or less"]);
        }

        var sender = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => new { x.Id, x.FullName })
            .FirstOrDefaultAsync();

        if (sender is null)
        {
            return ServiceResponse<ChatMessageResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var safeFileName = Path.GetFileName(file.FileName);
        if (string.IsNullOrWhiteSpace(safeFileName))
        {
            safeFileName = "attachment.bin";
        }

        var extension = Path.GetExtension(safeFileName);
        var objectKey = $"chat/{normalizedProjectId}/{DateTime.UtcNow:yyyyMMdd}/{Guid.NewGuid():N}{extension}";
        var contentType = string.IsNullOrWhiteSpace(file.ContentType)
            ? "application/octet-stream"
            : file.ContentType;

        await using var stream = file.OpenReadStream();
        var saved = await storageService.SaveAsync("Local", objectKey, stream, cancellationToken);
        if (!saved)
        {
            return ServiceResponse<ChatMessageResponse>.Failure("Upload failed", ["Cannot save attachment"]);
        }

        var messageType = contentType.StartsWith("image/", StringComparison.OrdinalIgnoreCase)
            ? "image"
            : "file";

        var trimmedCaption = string.IsNullOrWhiteSpace(caption) ? null : caption.Trim();
        if (trimmedCaption?.Length > 2000)
        {
            trimmedCaption = trimmedCaption[..2000];
        }

        var entity = new ProjectChatMessage
        {
            ProjectId = normalizedProjectId,
            SenderUserId = sender.Id,
            MessageType = messageType,
            Content = trimmedCaption,
            AttachmentObjectKey = objectKey,
            AttachmentFileName = safeFileName,
            AttachmentContentType = contentType,
            AttachmentSizeBytes = file.Length,
            CreatedAt = DlssTime.VietnamNow
        };

        dbContext.ProjectChatMessages.Add(entity);
        await dbContext.SaveChangesAsync();

        var preview = !string.IsNullOrWhiteSpace(trimmedCaption)
            ? trimmedCaption
            : messageType == "image"
                ? $"Sent an image ({safeFileName})"
                : $"Sent a file ({safeFileName})";

        var response = MapMessage(
            entity.Id,
            entity.ProjectId,
            entity.SenderUserId,
            sender.FullName,
            entity.MessageType,
            entity.Content,
            entity.AttachmentFileName,
            entity.AttachmentContentType,
            entity.AttachmentSizeBytes,
            entity.AttachmentObjectKey,
            entity.CreatedAt);

        await NotifyChatRecipientsAsync(actorUserId, sender.FullName, normalizedProjectId, entity.Id, preview);

        return ServiceResponse<ChatMessageResponse>.Success(response, "Sent");
    }

    public async Task<ServiceResponse<(Stream Stream, string ContentType, string FileName)?>> OpenAttachmentAsync(
        string actorUserId,
        string messageId,
        CancellationToken cancellationToken)
    {
        var normalizedMessageId = (messageId ?? string.Empty).Trim();
        var message = await dbContext.ProjectChatMessages
            .AsNoTracking()
            .Where(x => x.Id == normalizedMessageId)
            .Select(x => new { x.ProjectId, x.AttachmentObjectKey, x.AttachmentFileName, x.AttachmentContentType })
            .FirstOrDefaultAsync();

        if (message is null || string.IsNullOrWhiteSpace(message.AttachmentObjectKey))
        {
            return ServiceResponse<(Stream, string, string)?>.Failure(ErrorMessages.NotFound, ["Attachment not found"]);
        }

        var access = await projectMembershipService.EnsureProjectAccessAsync(actorUserId, message.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<(Stream, string, string)?>.Failure(access.Message, access.Errors);
        }

        var opened = await storageService.OpenReadAsync("Local", message.AttachmentObjectKey, cancellationToken);
        if (opened is null)
        {
            return ServiceResponse<(Stream, string, string)?>.Failure(ErrorMessages.NotFound, ["Attachment file not found"]);
        }

        var contentType = message.AttachmentContentType ?? opened.Value.ContentType;
        var fileName = message.AttachmentFileName ?? opened.Value.FileName;
        return ServiceResponse<(Stream, string, string)?>.Success((opened.Value.Stream, contentType, fileName), "OK");
    }

    private async Task NotifyChatRecipientsAsync(
        string actorUserId,
        string actorFullName,
        string projectId,
        string messageId,
        string preview)
    {
        var projectName = await dbContext.Projects
            .AsNoTracking()
            .Where(x => x.Id == projectId)
            .Select(x => x.Name)
            .FirstOrDefaultAsync() ?? "Project";

        await notificationService.NotifyChatMessageAsync(
            actorUserId,
            actorFullName,
            projectId,
            projectName,
            messageId,
            preview);
    }

    private static ChatMessageResponse MapMessage(
        string id,
        string projectId,
        string senderUserId,
        string senderFullName,
        string messageType,
        string? content,
        string? attachmentFileName,
        string? attachmentContentType,
        long? attachmentSizeBytes,
        string? attachmentObjectKey,
        DateTime createdAt)
    {
        var hasAttachment = !string.IsNullOrWhiteSpace(attachmentObjectKey);
        return new ChatMessageResponse(
            id,
            projectId,
            senderUserId,
            senderFullName,
            messageType,
            content,
            attachmentFileName,
            attachmentContentType,
            attachmentSizeBytes,
            hasAttachment ? $"/api/chat/messages/{id}/attachment" : null,
            createdAt);
    }
}
