using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;
using DataLabellingSupportSystem.Api.DTOs.Responses.Notifications;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.Realtime;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Notifications;

public interface INotificationService
{
    Task<ServiceResponse<List<NotificationResponse>>> GetMyNotificationsAsync(
        string userId,
        int page,
        int pageSize,
        bool unreadOnly);

    Task<ServiceResponse<int>> GetUnreadCountAsync(string userId);

    Task<ServiceResponse<int>> MarkReadAsync(string userId, MarkNotificationsReadRequest request);

    Task<ServiceResponse<int>> MarkAllReadAsync(string userId);

    Task NotifyChatMessageAsync(
        string actorUserId,
        string actorFullName,
        string projectId,
        string projectName,
        string messageId,
        string preview);

    Task<ServiceResponse<int>> SendProjectAnnouncementAsync(
        string actorUserId,
        string projectId,
        SendProjectNotificationRequest request);

    Task NotifyProjectAssignedAsync(
        string actorUserId,
        string actorFullName,
        string recipientUserId,
        string projectId,
        string projectName);
}

public sealed class NotificationService(
    AppDbContext dbContext,
    IRealtimePublisher realtimePublisher) : INotificationService
{
    public const string TypeChatMessage = "chat_message";
    public const string TypeProjectAnnounce = "project_announce";
    public const string TypeProjectAssigned = "project_assigned";

    public async Task<ServiceResponse<List<NotificationResponse>>> GetMyNotificationsAsync(
        string userId,
        int page,
        int pageSize,
        bool unreadOnly)
    {
        var safePage = Math.Max(1, page);
        var safePageSize = Math.Clamp(pageSize, 1, 100);
        var skip = (safePage - 1) * safePageSize;

        var query = dbContext.Notifications
            .AsNoTracking()
            .Where(x => x.RecipientUserId == userId);

        if (unreadOnly)
        {
            query = query.Where(x => !x.IsRead);
        }

        var rows = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip(skip)
            .Take(safePageSize)
            .Select(x => new
            {
                x.Id,
                x.Type,
                x.Title,
                x.Body,
                x.ProjectId,
                ProjectName = x.Project != null ? x.Project.Name : null,
                x.ActorUserId,
                ActorFullName = x.ActorUser != null ? x.ActorUser.FullName : null,
                x.RelatedEntityId,
                x.IsRead,
                x.CreatedAt
            })
            .ToListAsync();

        var items = rows
            .Select(x => new NotificationResponse(
                x.Id,
                x.Type,
                x.Title,
                x.Body,
                x.ProjectId,
                x.ProjectName,
                x.ActorUserId,
                x.ActorFullName,
                x.RelatedEntityId,
                x.IsRead,
                x.CreatedAt))
            .ToList();

        return ServiceResponse<List<NotificationResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<int>> GetUnreadCountAsync(string userId)
    {
        var count = await dbContext.Notifications
            .AsNoTracking()
            .CountAsync(x => x.RecipientUserId == userId && !x.IsRead);

        return ServiceResponse<int>.Success(count, "OK");
    }

    public async Task<ServiceResponse<int>> MarkReadAsync(string userId, MarkNotificationsReadRequest request)
    {
        var ids = (request.Ids ?? [])
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => x.Trim())
            .Distinct()
            .ToList();

        if (ids.Count == 0)
        {
            return ServiceResponse<int>.Failure("Invalid request", ["ids is required"]);
        }

        var rows = await dbContext.Notifications
            .Where(x => x.RecipientUserId == userId && ids.Contains(x.Id) && !x.IsRead)
            .ToListAsync();

        foreach (var row in rows)
        {
            row.IsRead = true;
        }

        if (rows.Count > 0)
        {
            await dbContext.SaveChangesAsync();
        }

        return ServiceResponse<int>.Success(rows.Count, "OK");
    }

    public async Task<ServiceResponse<int>> MarkAllReadAsync(string userId)
    {
        var rows = await dbContext.Notifications
            .Where(x => x.RecipientUserId == userId && !x.IsRead)
            .ToListAsync();

        foreach (var row in rows)
        {
            row.IsRead = true;
        }

        if (rows.Count > 0)
        {
            await dbContext.SaveChangesAsync();
        }

        return ServiceResponse<int>.Success(rows.Count, "OK");
    }

    public async Task NotifyChatMessageAsync(
        string actorUserId,
        string actorFullName,
        string projectId,
        string projectName,
        string messageId,
        string preview)
    {
        var recipientIds = await dbContext.UserProjectRoles
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId && x.UserId != actorUserId)
            .Select(x => x.UserId)
            .Distinct()
            .ToListAsync();

        if (recipientIds.Count == 0)
        {
            return;
        }

        var safePreview = Truncate(preview, 200);
        var title = $"{actorFullName} in {projectName}";
        var body = string.IsNullOrWhiteSpace(safePreview) ? "Sent a new message" : safePreview;
        var now = DlssTime.VietnamNow;

        var entities = recipientIds.Select(recipientId => new Notification
        {
            RecipientUserId = recipientId,
            ActorUserId = actorUserId,
            ProjectId = projectId,
            Type = TypeChatMessage,
            Title = Truncate(title, 200),
            Body = Truncate(body, 1000),
            RelatedEntityId = messageId,
            IsRead = false,
            CreatedAt = now
        }).ToList();

        await PersistAndEmitAsync(entities, projectName, actorFullName);
    }

    public async Task<ServiceResponse<int>> SendProjectAnnouncementAsync(
        string actorUserId,
        string projectId,
        SendProjectNotificationRequest request)
    {
        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        var title = (request.Title ?? string.Empty).Trim();
        var body = string.IsNullOrWhiteSpace(request.Body) ? null : request.Body.Trim();

        if (string.IsNullOrWhiteSpace(title))
        {
            return ServiceResponse<int>.Failure("Invalid request", ["Title is required"]);
        }

        if (title.Length > 200)
        {
            return ServiceResponse<int>.Failure("Invalid request", ["Title is too long"]);
        }

        if (body?.Length > 1000)
        {
            return ServiceResponse<int>.Failure("Invalid request", ["Body is too long"]);
        }

        var project = await dbContext.Projects
            .AsNoTracking()
            .Where(x => x.Id == normalizedProjectId)
            .Select(x => new { x.Id, x.Name })
            .FirstOrDefaultAsync();

        if (project is null)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var hasAccess = await dbContext.UserProjectRoles
            .AsNoTracking()
            .AnyAsync(x => x.ProjectId == normalizedProjectId && x.UserId == actorUserId);

        var isAdmin = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => x.Role != null && x.Role.Name == "Admin")
            .FirstOrDefaultAsync();

        if (!hasAccess && !isAdmin)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.Forbidden, ["No access to this project"]);
        }

        var actor = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => new { x.Id, x.FullName })
            .FirstOrDefaultAsync();

        if (actor is null)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        // Annotators + reviewers on the project (exclude the sender).
        var recipientIds = await (
            from upr in dbContext.UserProjectRoles.AsNoTracking()
            join role in dbContext.Roles.AsNoTracking() on upr.RoleId equals role.Id
            where upr.ProjectId == normalizedProjectId
                  && upr.UserId != actorUserId
                  && (role.Name == "Annotator" || role.Name == "Reviewer")
            select upr.UserId
        ).Distinct().ToListAsync();

        if (recipientIds.Count == 0)
        {
            return ServiceResponse<int>.Success(0, "No recipients");
        }

        var now = DlssTime.VietnamNow;
        var entities = recipientIds.Select(recipientId => new Notification
        {
            RecipientUserId = recipientId,
            ActorUserId = actor.Id,
            ProjectId = project.Id,
            Type = TypeProjectAnnounce,
            Title = title,
            Body = body,
            RelatedEntityId = project.Id,
            IsRead = false,
            CreatedAt = now
        }).ToList();

        await PersistAndEmitAsync(entities, project.Name, actor.FullName);
        return ServiceResponse<int>.Success(entities.Count, "Sent");
    }

    public async Task NotifyProjectAssignedAsync(
        string actorUserId,
        string actorFullName,
        string recipientUserId,
        string projectId,
        string projectName)
    {
        if (string.IsNullOrWhiteSpace(recipientUserId) || recipientUserId == actorUserId)
        {
            return;
        }

        var entity = new Notification
        {
            RecipientUserId = recipientUserId,
            ActorUserId = actorUserId,
            ProjectId = projectId,
            Type = TypeProjectAssigned,
            Title = $"Added to {projectName}",
            Body = $"{actorFullName} added you to project {projectName}",
            RelatedEntityId = projectId,
            IsRead = false,
            CreatedAt = DlssTime.VietnamNow
        };

        await PersistAndEmitAsync([entity], projectName, actorFullName);
    }

    private async Task PersistAndEmitAsync(
        List<Notification> entities,
        string? projectName,
        string? actorFullName)
    {
        if (entities.Count == 0)
        {
            return;
        }

        dbContext.Notifications.AddRange(entities);
        await dbContext.SaveChangesAsync();

        var deliveries = entities
            .Select(x => (
                x.RecipientUserId,
                new NotificationResponse(
                    x.Id,
                    x.Type,
                    x.Title,
                    x.Body,
                    x.ProjectId,
                    projectName,
                    x.ActorUserId,
                    actorFullName,
                    x.RelatedEntityId,
                    x.IsRead,
                    x.CreatedAt)))
            .ToList();

        await realtimePublisher.EmitNotificationsAsync(deliveries);
    }

    private static string Truncate(string? value, int max)
    {
        if (string.IsNullOrEmpty(value))
        {
            return string.Empty;
        }

        return value.Length <= max ? value : value[..max];
    }
}
