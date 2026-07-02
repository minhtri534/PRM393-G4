using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Projects;

public interface IProjectMembershipService
{
    Task<ServiceResponse<bool>?> EnsureProjectAccessAsync(string actorUserId, string projectId);
    Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string actorUserId);
    Task<bool> HasProjectAccessAsync(string actorUserId, string projectId);
}

public sealed class ProjectMembershipService(AppDbContext dbContext) : IProjectMembershipService
{
    private static readonly HashSet<string> TodoStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "Assigned", "InProgress", "Returned", "Rejected", "Rework"
    };

    private static readonly HashSet<string> DoneStatuses = new(StringComparer.OrdinalIgnoreCase)
    {
        "Submitted", "Completed", "Approved"
    };

    public async Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string actorUserId)
    {
        var normalizedActorId = (actorUserId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalizedActorId))
        {
            return ServiceResponse<List<MyProjectSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing actor user id"]);
        }

        List<string> accessibleProjectIds;
        if (await IsSystemAdminAsync(normalizedActorId))
        {
            accessibleProjectIds = await dbContext.Projects
                .AsNoTracking()
                .Select(x => x.Id)
                .ToListAsync();
        }
        else
        {
            accessibleProjectIds = await dbContext.UserProjectRoles
                .AsNoTracking()
                .Where(x => x.UserId == normalizedActorId)
                .Select(x => x.ProjectId)
                .Distinct()
                .ToListAsync();
        }

        if (accessibleProjectIds.Count == 0)
        {
            return ServiceResponse<List<MyProjectSummaryResponse>>.Success([], "OK");
        }

        var projects = await dbContext.Projects
            .AsNoTracking()
            .Where(x => accessibleProjectIds.Contains(x.Id))
            .OrderByDescending(x => x.UpdatedAt)
            .Select(x => new { x.Id, x.Name, x.Guideline })
            .ToListAsync();

        var userTasks = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => accessibleProjectIds.Contains(x.ProjectId) && x.AnnotatorId == normalizedActorId)
            .Select(x => new { x.ProjectId, x.Status })
            .ToListAsync();

        var recentMessages = await dbContext.ProjectChatMessages
            .AsNoTracking()
            .Where(x => accessibleProjectIds.Contains(x.ProjectId))
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new
            {
                x.ProjectId,
                x.CreatedAt,
                x.Content,
                x.MessageType,
                x.AttachmentFileName
            })
            .ToListAsync();

        var lastMessages = recentMessages
            .GroupBy(x => x.ProjectId)
            .Select(g => g.First())
            .ToList();

        var items = projects.Select(project =>
        {
            var projectTasks = userTasks.Where(x => x.ProjectId == project.Id).ToList();
            var todo = projectTasks.Count(x => TodoStatuses.Contains(x.Status));
            var done = projectTasks.Count(x => DoneStatuses.Contains(x.Status));
            var last = lastMessages.FirstOrDefault(x => x.ProjectId == project.Id);
            var preview = BuildPreview(last?.MessageType, last?.Content, last?.AttachmentFileName);

            return new MyProjectSummaryResponse(
                project.Id,
                project.Name,
                project.Guideline,
                todo,
                done,
                last?.CreatedAt,
                preview);
        }).ToList();

        return ServiceResponse<List<MyProjectSummaryResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<bool>?> EnsureProjectAccessAsync(string actorUserId, string projectId)
    {
        var normalizedActorUserId = (actorUserId ?? string.Empty).Trim();
        var normalizedProjectId = (projectId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(normalizedActorUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing actor user id"]);
        }

        if (string.IsNullOrWhiteSpace(normalizedProjectId))
        {
            return ServiceResponse<bool>.Failure("Invalid project", ["Project id is required"]);
        }

        var projectExists = await dbContext.Projects
            .AsNoTracking()
            .AnyAsync(x => x.Id == normalizedProjectId);

        if (!projectExists)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        if (!await HasProjectAccessAsync(normalizedActorUserId, normalizedProjectId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this project"]);
        }

        return null;
    }

    public async Task<bool> HasProjectAccessAsync(string actorUserId, string projectId)
    {
        var normalizedActorUserId = (actorUserId ?? string.Empty).Trim();
        var normalizedProjectId = (projectId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(normalizedActorUserId) || string.IsNullOrWhiteSpace(normalizedProjectId))
        {
            return false;
        }

        if (await IsSystemAdminAsync(normalizedActorUserId))
        {
            return true;
        }

        return await dbContext.UserProjectRoles
            .AsNoTracking()
            .AnyAsync(x => x.UserId == normalizedActorUserId && x.ProjectId == normalizedProjectId);
    }

    private async Task<bool> IsSystemAdminAsync(string actorUserId)
    {
        var roleName = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => x.Role != null ? x.Role.Name : string.Empty)
            .FirstOrDefaultAsync();

        return string.Equals(roleName, "Admin", StringComparison.OrdinalIgnoreCase);
    }

    private static string? BuildPreview(string? messageType, string? content, string? fileName)
    {
        var type = (messageType ?? "text").Trim().ToLowerInvariant();
        return type switch
        {
            "image" => "📷 Image",
            "file" => string.IsNullOrWhiteSpace(fileName) ? "📎 File" : $"📎 {fileName.Trim()}",
            _ => string.IsNullOrWhiteSpace(content) ? null : content.Trim()
        };
    }
}
