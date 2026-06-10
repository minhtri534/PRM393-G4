using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Annotator;

public sealed partial class AnnotatorService
{
    public async Task<ServiceResponse<List<LabelResponse>>> GetTaskLabelsAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<List<LabelResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<LabelResponse>>.Failure("Invalid task", ["Task id is required"]);
        }

        var task = await _dbContext.LabelingTasks
            .AsNoTracking()
            .Select(x => new { x.Id, x.ProjectId, x.AnnotatorId })
            .FirstOrDefaultAsync(x => x.Id == id);

        if (task is null)
        {
            return ServiceResponse<List<LabelResponse>>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<List<LabelResponse>>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var labels = await _dbContext.Labels
            .AsNoTracking()
            .Where(x => x.ProjectId == task.ProjectId)
            .OrderBy(x => x.YoloClassId)
            .ThenBy(x => x.Name)
            .Select(x => new LabelResponse(x.Id, x.Name, x.YoloClassId))
            .ToListAsync();

        return ServiceResponse<List<LabelResponse>>.Success(labels, "OK");
    }

    public async Task<ServiceResponse<ProjectGuidelineResponse>> GetTaskGuidelineAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<ProjectGuidelineResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<ProjectGuidelineResponse>.Failure("Invalid task", ["Task id is required"]);
        }

        var task = await _dbContext.LabelingTasks
            .AsNoTracking()
            .Select(x => new { x.Id, x.ProjectId, x.AnnotatorId })
            .FirstOrDefaultAsync(x => x.Id == id);

        if (task is null)
        {
            return ServiceResponse<ProjectGuidelineResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<ProjectGuidelineResponse>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var project = await _dbContext.Projects
            .AsNoTracking()
            .Where(x => x.Id == task.ProjectId)
            .Select(x => new { x.Id, x.Guideline })
            .FirstOrDefaultAsync();

        if (project is null)
        {
            return ServiceResponse<ProjectGuidelineResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        return ServiceResponse<ProjectGuidelineResponse>.Success(
            new ProjectGuidelineResponse(project.Id, project.Guideline),
            "OK");
    }
}
