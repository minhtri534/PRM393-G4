using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.Projects;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Annotator;

public sealed partial class AnnotatorService
{
    public Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string userId) =>
        projectMembershipService.GetMyProjectsAsync(userId);

    public async Task<ServiceResponse<List<AnnotatorTaskSummaryResponse>>> GetMyTasksAsync(string userId, string? projectId = null)
    {
        var uid = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<List<AnnotatorTaskSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        var normalizedProjectId = string.IsNullOrWhiteSpace(projectId) ? null : projectId.Trim();
        if (normalizedProjectId is not null)
        {
            var access = await projectMembershipService.EnsureProjectAccessAsync(uid, normalizedProjectId);
            if (access is not null)
            {
                return ServiceResponse<List<AnnotatorTaskSummaryResponse>>.Failure(access.Message, access.Errors);
            }
        }

        var query = _dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.AnnotatorId == uid);

        if (normalizedProjectId is not null)
        {
            query = query.Where(x => x.ProjectId == normalizedProjectId);
        }

        var tasks = await query
            .OrderByDescending(x => x.AssignedAt)
            .Select(x => new AnnotatorTaskSummaryResponse(
                x.Id,
                x.ProjectId,
                x.DataItemId,
                x.Status,
                x.AssignedAt,
                x.CompletedAt,
                x.Project != null ? x.Project.Name : null,
                x.DataItem != null ? x.DataItem.ObjectKey : null,
                x.DataItem != null && x.DataItem.Dataset != null ? x.DataItem.Dataset.Name : null))
            .ToListAsync();

        return ServiceResponse<List<AnnotatorTaskSummaryResponse>>.Success(tasks, "OK");
    }

    public async Task<ServiceResponse<bool>> StartTaskAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid task", ["Task id is required"]);
        }

        var task = await _dbContext.LabelingTasks.FirstOrDefaultAsync(x => x.Id == id);
        if (task is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var now = DlssTime.VietnamNow;

        if (string.Equals(task.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
        {
            var oldStatus = task.Status;
            task.Status = "InProgress";

            _dbContext.TaskHistories.Add(new TaskHistory
            {
                TaskId = task.Id,
                OldStatus = oldStatus,
                NewStatus = task.Status,
                ChangedByUserId = uid
            });
        }

        task.AssignedAt ??= now;

        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Started");
    }

    public async Task<ServiceResponse<List<AnnotatorTaskItemResponse>>> GetTaskItemsAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<List<AnnotatorTaskItemResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<AnnotatorTaskItemResponse>>.Failure("Invalid task", ["Task id is required"]);
        }

        var item = await _dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new
            {
                x.Id,
                x.AnnotatorId,
                x.DataItemId,
                StorageProvider = x.DataItem != null ? x.DataItem.StorageProvider : null,
                ObjectKey = x.DataItem != null ? x.DataItem.ObjectKey : null,
                OriginalWidth = x.DataItem != null ? x.DataItem.OriginalWidth : 0,
                OriginalHeight = x.DataItem != null ? x.DataItem.OriginalHeight : 0
            })
            .FirstOrDefaultAsync();

        if (item is null)
        {
            return ServiceResponse<List<AnnotatorTaskItemResponse>>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(item.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<List<AnnotatorTaskItemResponse>>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var items = new List<AnnotatorTaskItemResponse>
        {
            new(
                item.Id,
                item.DataItemId,
                item.StorageProvider ?? string.Empty,
                item.ObjectKey ?? string.Empty,
                item.OriginalWidth,
                item.OriginalHeight)
        };

        return ServiceResponse<List<AnnotatorTaskItemResponse>>.Success(items, "OK");
    }
}
