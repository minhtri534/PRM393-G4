using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Annotator;

public sealed partial class AnnotatorService
{
    public async Task<ServiceResponse<TaskDataItemStorageResponse>> GetTaskDataItemStorageAsync(
        string userId,
        string taskId,
        CancellationToken cancellationToken)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure("Invalid task", ["Task id is required"]);
        }

        var item = await _dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new
            {
                AnnotatorId = x.AnnotatorId,
                StorageProvider = x.DataItem != null ? x.DataItem.StorageProvider : null,
                ObjectKey = x.DataItem != null ? x.DataItem.ObjectKey : null
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (item is null)
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(item.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        if (string.IsNullOrWhiteSpace(item.StorageProvider) || string.IsNullOrWhiteSpace(item.ObjectKey))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.NotFound, ["Data item not found"]);
        }

        return ServiceResponse<TaskDataItemStorageResponse>.Success(
            new TaskDataItemStorageResponse(item.StorageProvider, item.ObjectKey),
            "OK");
    }
}
