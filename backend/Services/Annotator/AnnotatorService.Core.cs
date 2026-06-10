using System.Text.Json;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Annotator;

public sealed partial class AnnotatorService(AppDbContext dbContext) : IAnnotatorService
{
    private readonly AppDbContext _dbContext = dbContext;

    public async Task<ServiceResponse<List<AnnotatorAnnotationResponse>>> GetTaskAnnotationsAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var id = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<List<AnnotatorAnnotationResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<AnnotatorAnnotationResponse>>.Failure("Invalid task", ["Task id is required"]);
        }

        var task = await _dbContext.LabelingTasks
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == id);

        if (task is null)
        {
            return ServiceResponse<List<AnnotatorAnnotationResponse>>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<List<AnnotatorAnnotationResponse>>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var sets = await _dbContext.AnnotationSets
            .AsNoTracking()
            .Where(x => x.TaskId == id && x.CreatedByUserId == uid)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new { x.Id, x.Status, x.CreatedAt })
            .ToListAsync();

        var draftSet = sets.FirstOrDefault(x => string.Equals(x.Status, "Draft", StringComparison.OrdinalIgnoreCase));
        var submittedSet = sets.FirstOrDefault(x => string.Equals(x.Status, "Submitted", StringComparison.OrdinalIgnoreCase));

        var setIds = new List<string>(2);
        if (draftSet is not null) setIds.Add(draftSet.Id);
        if (submittedSet is not null) setIds.Add(submittedSet.Id);

        if (setIds.Count == 0)
        {
            return ServiceResponse<List<AnnotatorAnnotationResponse>>.Success([], "OK");
        }

        var annotations = await _dbContext.Annotations
            .AsNoTracking()
            .Where(x => setIds.Contains(x.AnnotationSetId))
            .Select(x => new { x.Id, x.AnnotationSetId, x.LabelId, x.GeometryData, x.CreatedAt, x.UpdatedAt })
            .ToListAsync();

        var submittedAt = submittedSet?.CreatedAt;

        var response = annotations
            .Select(x => new AnnotatorAnnotationResponse(
                x.Id,
                x.LabelId,
                x.GeometryData,
                IsDraft: draftSet is not null && string.Equals(x.AnnotationSetId, draftSet.Id, StringComparison.Ordinal),
                x.CreatedAt,
                x.UpdatedAt,
                SubmittedAt: submittedSet is not null && string.Equals(x.AnnotationSetId, submittedSet.Id, StringComparison.Ordinal) ? submittedAt : null))
            .OrderByDescending(x => x.IsDraft)
            .ThenByDescending(x => x.UpdatedAt)
            .ToList();

        return ServiceResponse<List<AnnotatorAnnotationResponse>>.Success(response, "OK");
    }

    public Task<ServiceResponse<bool>> SaveTaskAnnotationsDraftAsync(string userId, string taskId, UpsertTaskItemAnnotationsRequest request)
        => UpsertTaskAnnotationsAsync(userId, taskId, request, isDraft: true);

    public Task<ServiceResponse<bool>> SubmitTaskAnnotationsAsync(string userId, string taskId, UpsertTaskItemAnnotationsRequest request)
        => UpsertTaskAnnotationsAsync(userId, taskId, request, isDraft: false);

    private async Task<ServiceResponse<bool>> UpsertTaskAnnotationsAsync(
        string userId,
        string taskId,
        UpsertTaskItemAnnotationsRequest request,
        bool isDraft)
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

        var task = await _dbContext.LabelingTasks
            .FirstOrDefaultAsync(x => x.Id == id);

        if (task is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        var labelIds = request.Objects
            .Select(x => (x.LabelId ?? string.Empty).Trim())
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (labelIds.Count == 0)
        {
            return ServiceResponse<bool>.Failure("Invalid annotations", ["At least one object is required"]);
        }

        var projectId = task.ProjectId;
        var validLabelIds = await _dbContext.Labels
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId && labelIds.Contains(x.Id))
            .Select(x => x.Id)
            .ToListAsync();

        var missing = labelIds.Except(validLabelIds, StringComparer.Ordinal).ToList();
        if (missing.Count > 0)
        {
            return ServiceResponse<bool>.Failure("Invalid label", missing.Select(x => $"Label not found in project: {x}").ToList());
        }

        var now = DlssTime.VietnamNow;

        var annotationSetStatus = isDraft ? "Draft" : "Submitted";

        AnnotationSet set;

        if (isDraft)
        {
            set = await _dbContext.AnnotationSets
                .FirstOrDefaultAsync(x => x.TaskId == id && x.CreatedByUserId == uid && x.Status == annotationSetStatus)
                ?? new AnnotationSet
                {
                    Id = ObjectId.NewObjectId(),
                    TaskId = id,
                    CreatedByUserId = uid,
                    Status = annotationSetStatus
                };

            if (_dbContext.Entry(set).State == EntityState.Detached)
            {
                _dbContext.AnnotationSets.Add(set);
            }
            else
            {
                var existing = await _dbContext.Annotations
                    .Where(x => x.AnnotationSetId == set.Id)
                    .ToListAsync();

                _dbContext.Annotations.RemoveRange(existing);
            }
        }
        else
        {
            set = new AnnotationSet
            {
                Id = ObjectId.NewObjectId(),
                TaskId = id,
                CreatedByUserId = uid,
                Status = annotationSetStatus
            };

            _dbContext.AnnotationSets.Add(set);
        }

        foreach (var obj in request.Objects)
        {
            var labelId = (obj.LabelId ?? string.Empty).Trim();
            var geometryJson = obj.GeometryData.ValueKind == JsonValueKind.Undefined
                ? string.Empty
                : obj.GeometryData.GetRawText();

            if (string.IsNullOrWhiteSpace(labelId) || string.IsNullOrWhiteSpace(geometryJson))
            {
                continue;
            }

            _dbContext.Annotations.Add(new Annotation
            {
                AnnotationSetId = set.Id,
                LabelId = labelId,
                AnnotationType = TryReadGeometryType(geometryJson) ?? "bbox",
                GeometryData = geometryJson,
                Version = 1
            });
        }

        if (string.Equals(task.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
        {
            var oldStatus = task.Status;
            task.Status = "InProgress";
            task.AssignedAt ??= now;

            _dbContext.TaskHistories.Add(new TaskHistory
            {
                TaskId = task.Id,
                OldStatus = oldStatus,
                NewStatus = task.Status,
                ChangedByUserId = uid
            });
        }

        if (!isDraft)
        {
            var oldStatus = task.Status;
            task.Status = "Submitted";
            task.CompletedAt = now;

            if (!string.Equals(oldStatus, task.Status, StringComparison.Ordinal))
            {
                _dbContext.TaskHistories.Add(new TaskHistory
                {
                    TaskId = task.Id,
                    OldStatus = oldStatus,
                    NewStatus = task.Status,
                    ChangedByUserId = uid
                });
            }
        }

        var predictionId = (request.PredictionId ?? string.Empty).Trim();
        if (!string.IsNullOrWhiteSpace(predictionId))
        {
            var prediction = await _dbContext.AiPredictions
                .FirstOrDefaultAsync(x => x.Id == predictionId);

            if (prediction is not null)
            {
                prediction.TaskId = task.Id;
                prediction.IsAccepted = true;
                prediction.Decision = "Accepted";
                prediction.AcceptedByUserId = uid;
                prediction.AcceptedAt = now;
                prediction.AppliedAnnotationSetId = set.Id;
            }
        }

        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, isDraft ? "Draft saved" : "Submitted");
    }

    public Task<ServiceResponse<bool>> AcceptTaskAsync(string userId, string taskId)
        => StartTaskAsync(userId, taskId);

    public async Task<ServiceResponse<bool>> RejectTaskAsync(string userId, string taskId, RejectTaskRequest request)
    {
        var taskResult = await GetAssignedTaskAsync(userId, taskId);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(taskResult.Message, taskResult.Errors);
        }

        var task = taskResult.Data;
        var oldStatus = task.Status;
        task.Status = "Cancelled";

        _dbContext.TaskHistories.Add(new TaskHistory
        {
            TaskId = task.Id,
            OldStatus = oldStatus,
            NewStatus = task.Status,
            ChangedByUserId = task.AnnotatorId
        });

        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, string.IsNullOrWhiteSpace(request.Reason) ? "Task rejected" : request.Reason.Trim());
    }

    public async Task<ServiceResponse<AnnotatorAnnotationResponse>> CreateTaskAnnotationAsync(string userId, string taskId, CreateTaskAnnotationRequest request)
    {
        var taskResult = await GetAssignedTaskAsync(userId, taskId);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure(taskResult.Message, taskResult.Errors);
        }

        var task = taskResult.Data;
        var labelValidation = await ValidateLabelAsync(task.ProjectId, request.LabelId);
        if (!labelValidation.IsSuccess)
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure(labelValidation.Message, labelValidation.Errors);
        }

        var geometryJson = request.GeometryData.ValueKind == JsonValueKind.Undefined
            ? string.Empty
            : request.GeometryData.GetRawText();

        if (string.IsNullOrWhiteSpace(geometryJson))
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure("Invalid annotations", ["GeometryData is required"]);
        }

        var draftSet = await GetOrCreateDraftSetAsync(task.Id, task.AnnotatorId);

        var now = DlssTime.VietnamNow;
        var annotation = new Annotation
        {
            AnnotationSetId = draftSet.Id,
            LabelId = request.LabelId.Trim(),
            AnnotationType = TryReadGeometryType(geometryJson) ?? "bbox",
            GeometryData = geometryJson,
            Version = 1,
            CreatedAt = now,
            UpdatedAt = now
        };

        _dbContext.Annotations.Add(annotation);

        if (string.Equals(task.Status, "Assigned", StringComparison.OrdinalIgnoreCase))
        {
            var oldStatus = task.Status;
            task.Status = "InProgress";
            task.AssignedAt ??= now;

            _dbContext.TaskHistories.Add(new TaskHistory
            {
                TaskId = task.Id,
                OldStatus = oldStatus,
                NewStatus = task.Status,
                ChangedByUserId = task.AnnotatorId
            });
        }

        await TryMarkPredictionAcceptedAsync(request.PredictionId, task.Id, task.AnnotatorId, draftSet.Id, now);
        await _dbContext.SaveChangesAsync();

        return ServiceResponse<AnnotatorAnnotationResponse>.Success(
            new AnnotatorAnnotationResponse(
                annotation.Id,
                annotation.LabelId,
                annotation.GeometryData,
                IsDraft: true,
                annotation.CreatedAt,
                annotation.UpdatedAt,
                SubmittedAt: null),
            "Created");
    }

    public async Task<ServiceResponse<AnnotatorAnnotationResponse>> UpdateTaskAnnotationAsync(string userId, string taskId, string annotationId, UpdateTaskAnnotationRequest request)
    {
        var taskResult = await GetAssignedTaskAsync(userId, taskId);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure(taskResult.Message, taskResult.Errors);
        }

        var task = taskResult.Data;
        var aid = (annotationId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(aid))
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure("Invalid annotation", ["Annotation id is required"]);
        }

        var annotation = await _dbContext.Annotations
            .FirstOrDefaultAsync(x =>
                x.Id == aid
                && x.AnnotationSet != null
                && x.AnnotationSet.TaskId == task.Id
                && x.AnnotationSet.CreatedByUserId == task.AnnotatorId
                && x.AnnotationSet.Status == "Draft");

        if (annotation is null)
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure(ErrorMessages.NotFound, ["Draft annotation not found"]);
        }

        var labelValidation = await ValidateLabelAsync(task.ProjectId, request.LabelId);
        if (!labelValidation.IsSuccess)
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure(labelValidation.Message, labelValidation.Errors);
        }

        var geometryJson = request.GeometryData.ValueKind == JsonValueKind.Undefined
            ? string.Empty
            : request.GeometryData.GetRawText();

        if (string.IsNullOrWhiteSpace(geometryJson))
        {
            return ServiceResponse<AnnotatorAnnotationResponse>.Failure("Invalid annotations", ["GeometryData is required"]);
        }

        var now = DlssTime.VietnamNow;
        annotation.LabelId = request.LabelId.Trim();
        annotation.GeometryData = geometryJson;
        annotation.AnnotationType = TryReadGeometryType(geometryJson) ?? "bbox";
        annotation.Version += 1;
        annotation.UpdatedAt = now;

        await TryMarkPredictionAcceptedAsync(request.PredictionId, task.Id, task.AnnotatorId, annotation.AnnotationSetId, now);
        await _dbContext.SaveChangesAsync();

        return ServiceResponse<AnnotatorAnnotationResponse>.Success(
            new AnnotatorAnnotationResponse(
                annotation.Id,
                annotation.LabelId,
                annotation.GeometryData,
                IsDraft: true,
                annotation.CreatedAt,
                annotation.UpdatedAt,
                SubmittedAt: null),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteTaskAnnotationAsync(string userId, string taskId, string annotationId)
    {
        var taskResult = await GetAssignedTaskAsync(userId, taskId);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(taskResult.Message, taskResult.Errors);
        }

        var task = taskResult.Data;
        var aid = (annotationId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(aid))
        {
            return ServiceResponse<bool>.Failure("Invalid annotation", ["Annotation id is required"]);
        }

        var annotation = await _dbContext.Annotations
            .FirstOrDefaultAsync(x =>
                x.Id == aid
                && x.AnnotationSet != null
                && x.AnnotationSet.TaskId == task.Id
                && x.AnnotationSet.CreatedByUserId == task.AnnotatorId
                && x.AnnotationSet.Status == "Draft");

        if (annotation is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Draft annotation not found"]);
        }

        _dbContext.Annotations.Remove(annotation);
        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<AnnotatorReviewFeedbackResponse>> GetTaskReviewFeedbackAsync(string userId, string taskId)
    {
        var taskResult = await GetAssignedTaskAsync(userId, taskId);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<AnnotatorReviewFeedbackResponse>.Failure(taskResult.Message, taskResult.Errors);
        }

        var task = taskResult.Data;

        var review = await _dbContext.Reviews
            .AsNoTracking()
            .Where(x => x.AnnotationSet != null && x.AnnotationSet.TaskId == task.Id && x.AnnotationSet.CreatedByUserId == task.AnnotatorId)
            .OrderByDescending(x => x.ReviewedAt)
            .Select(x => new
            {
                x.Id,
                x.AnnotationSetId,
                x.Result,
                x.Score,
                x.Comment,
                x.ReviewedAt
            })
            .FirstOrDefaultAsync();

        if (review is null)
        {
            return ServiceResponse<AnnotatorReviewFeedbackResponse>.Failure(ErrorMessages.NotFound, ["No review feedback found for this task"]);
        }

        var categories = await _dbContext.ReviewErrors
            .AsNoTracking()
            .Where(x => x.ReviewId == review.Id)
            .Select(x => new AnnotatorReviewErrorCategoryResponse(
                x.ErrorTypeId,
                x.ErrorType != null ? x.ErrorType.ErrorName : string.Empty,
                x.ErrorType != null ? x.ErrorType.Description : null))
            .ToListAsync();

        return ServiceResponse<AnnotatorReviewFeedbackResponse>.Success(
            new AnnotatorReviewFeedbackResponse(
                review.Id,
                review.AnnotationSetId,
                review.Result,
                review.Score,
                review.Comment,
                review.ReviewedAt,
                categories),
            "OK");
    }

    public async Task<ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>> GetReviewErrorCategoriesAsync(string userId, string reviewId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var rid = (reviewId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(rid))
        {
            return ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>.Failure("Invalid review", ["Review id is required"]);
        }

        var canAccess = await _dbContext.Reviews
            .AsNoTracking()
            .AnyAsync(x => x.Id == rid && x.AnnotationSet != null && x.AnnotationSet.CreatedByUserId == uid);

        if (!canAccess)
        {
            return ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>.Failure(ErrorMessages.Forbidden, ["You do not have access to this review"]);
        }

        var categories = await _dbContext.ReviewErrors
            .AsNoTracking()
            .Where(x => x.ReviewId == rid)
            .Select(x => new AnnotatorReviewErrorCategoryResponse(
                x.ErrorTypeId,
                x.ErrorType != null ? x.ErrorType.ErrorName : string.Empty,
                x.ErrorType != null ? x.ErrorType.Description : null))
            .ToListAsync();

        return ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>.Success(categories, "OK");
    }

    public async Task<ServiceResponse<bool>> AddCommentToReviewerAsync(string userId, string reviewId, AddReviewerCommentRequest request)
    {
        var uid = (userId ?? string.Empty).Trim();
        var rid = (reviewId ?? string.Empty).Trim();
        var comment = (request.Comment ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(rid))
        {
            return ServiceResponse<bool>.Failure("Invalid review", ["Review id is required"]);
        }

        if (string.IsNullOrWhiteSpace(comment))
        {
            return ServiceResponse<bool>.Failure("Invalid comment", ["Comment is required"]);
        }

        var review = await _dbContext.Reviews
            .FirstOrDefaultAsync(x => x.Id == rid && x.AnnotationSet != null && x.AnnotationSet.CreatedByUserId == uid);

        if (review is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this review"]);
        }

        var line = $"[Annotator:{uid} {DlssTime.VietnamNow:O}] {comment}";
        review.Comment = string.IsNullOrWhiteSpace(review.Comment)
            ? line
            : $"{review.Comment}{Environment.NewLine}{line}";

        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Comment added");
    }

    public async Task<ServiceResponse<bool>> AcceptAiSuggestionAsync(string userId, string taskId, string predictionId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var tid = (taskId ?? string.Empty).Trim();
        var pid = (predictionId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(tid) || string.IsNullOrWhiteSpace(pid))
        {
            return ServiceResponse<bool>.Failure("Invalid request", ["Task id and prediction id are required"]);
        }

        var taskResult = await GetAssignedTaskAsync(uid, tid);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(taskResult.Message, taskResult.Errors);
        }

        var prediction = await _dbContext.AiPredictions
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == pid && x.TaskId == tid);

        if (prediction is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["AI prediction not found"]);
        }

        var objects = ParseObjectsFromPrediction(prediction.PredictionData);
        if (objects.Count == 0)
        {
            return ServiceResponse<bool>.Failure("Invalid prediction", ["Prediction has no objects"]);
        }

        var save = await SaveTaskAnnotationsDraftAsync(uid, tid, new UpsertTaskItemAnnotationsRequest(objects, pid));
        if (!save.IsSuccess)
        {
            return ServiceResponse<bool>.Failure(save.Message, save.Errors);
        }

        return ServiceResponse<bool>.Success(true, "AI suggestion accepted");
    }

    public async Task<ServiceResponse<bool>> RejectAiSuggestionAsync(string userId, string taskId, string predictionId, RejectAiSuggestionRequest request)
    {
        var uid = (userId ?? string.Empty).Trim();
        var tid = (taskId ?? string.Empty).Trim();
        var pid = (predictionId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(tid) || string.IsNullOrWhiteSpace(pid))
        {
            return ServiceResponse<bool>.Failure("Invalid request", ["Task id and prediction id are required"]);
        }

        var taskResult = await GetAssignedTaskAsync(uid, tid);
        if (!taskResult.IsSuccess || taskResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(taskResult.Message, taskResult.Errors);
        }

        var prediction = await _dbContext.AiPredictions
            .FirstOrDefaultAsync(x => x.Id == pid && x.TaskId == tid);

        if (prediction is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["AI prediction not found"]);
        }

        prediction.IsAccepted = false;
        prediction.Decision = string.IsNullOrWhiteSpace(request.Reason)
            ? "Rejected"
            : $"Rejected:{request.Reason!.Trim()}";
        prediction.AcceptedByUserId = uid;
        prediction.AcceptedAt = DlssTime.VietnamNow;

        await _dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "AI suggestion rejected");
    }

    private async Task<ServiceResponse<bool>> ValidateLabelAsync(string projectId, string labelId)
    {
        var lid = (labelId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(lid))
        {
            return ServiceResponse<bool>.Failure("Invalid label", ["LabelId is required"]);
        }

        var exists = await _dbContext.Labels
            .AsNoTracking()
            .AnyAsync(x => x.ProjectId == projectId && x.Id == lid);

        return exists
            ? ServiceResponse<bool>.Success(true, "OK")
            : ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Label not found in project"]);
    }

    private async Task<AnnotationSet> GetOrCreateDraftSetAsync(string taskId, string userId)
    {
        var draftSet = await _dbContext.AnnotationSets
            .FirstOrDefaultAsync(x => x.TaskId == taskId && x.CreatedByUserId == userId && x.Status == "Draft");

        if (draftSet is not null)
        {
            return draftSet;
        }

        draftSet = new AnnotationSet
        {
            Id = ObjectId.NewObjectId(),
            TaskId = taskId,
            CreatedByUserId = userId,
            Status = "Draft"
        };

        _dbContext.AnnotationSets.Add(draftSet);
        return draftSet;
    }

    private async Task<ServiceResponse<LabelingTask>> GetAssignedTaskAsync(string userId, string taskId)
    {
        var uid = (userId ?? string.Empty).Trim();
        var tid = (taskId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<LabelingTask>.Failure(ErrorMessages.Unauthorized, ["Missing user id"]);
        }

        if (string.IsNullOrWhiteSpace(tid))
        {
            return ServiceResponse<LabelingTask>.Failure("Invalid task", ["Task id is required"]);
        }

        var task = await _dbContext.LabelingTasks.FirstOrDefaultAsync(x => x.Id == tid);
        if (task is null)
        {
            return ServiceResponse<LabelingTask>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        if (!string.Equals(task.AnnotatorId, uid, StringComparison.Ordinal))
        {
            return ServiceResponse<LabelingTask>.Failure(ErrorMessages.Forbidden, ["Task is not assigned to you"]);
        }

        return ServiceResponse<LabelingTask>.Success(task, "OK");
    }

    private static List<UpsertAnnotationObject> ParseObjectsFromPrediction(string predictionJson)
    {
        var result = new List<UpsertAnnotationObject>();
        if (string.IsNullOrWhiteSpace(predictionJson))
        {
            return result;
        }

        try
        {
            using var doc = JsonDocument.Parse(predictionJson);
            if (!doc.RootElement.TryGetProperty("objects", out var objects) || objects.ValueKind != JsonValueKind.Array)
            {
                return result;
            }

            foreach (var item in objects.EnumerateArray())
            {
                if (!item.TryGetProperty("LabelId", out var labelProp))
                {
                    continue;
                }

                var labelId = (labelProp.GetString() ?? string.Empty).Trim();
                if (string.IsNullOrWhiteSpace(labelId))
                {
                    continue;
                }

                if (!item.TryGetProperty("GeometryData", out var geometryProp))
                {
                    continue;
                }

                if (geometryProp.ValueKind != JsonValueKind.String)
                {
                    continue;
                }

                var geometryJson = geometryProp.GetString() ?? string.Empty;
                if (string.IsNullOrWhiteSpace(geometryJson))
                {
                    continue;
                }

                using var geometryDoc = JsonDocument.Parse(geometryJson);
                result.Add(new UpsertAnnotationObject(labelId, geometryDoc.RootElement.Clone()));
            }
        }
        catch
        {
            return [];
        }

        return result;
    }

    private async Task TryMarkPredictionAcceptedAsync(string? predictionId, string taskId, string userId, string annotationSetId, DateTime at)
    {
        var pid = (predictionId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(pid))
        {
            return;
        }

        var prediction = await _dbContext.AiPredictions
            .FirstOrDefaultAsync(x => x.Id == pid && x.TaskId == taskId);

        if (prediction is null)
        {
            return;
        }

        prediction.IsAccepted = true;
        prediction.Decision = "Accepted";
        prediction.AcceptedByUserId = userId;
        prediction.AcceptedAt = at;
        prediction.AppliedAnnotationSetId = annotationSetId;
    }

    private static string? TryReadGeometryType(string geometryJson)
    {
        if (string.IsNullOrWhiteSpace(geometryJson))
        {
            return null;
        }

        try
        {
            using var doc = JsonDocument.Parse(geometryJson);
            if (doc.RootElement.ValueKind != JsonValueKind.Object)
            {
                return null;
            }

            return doc.RootElement.TryGetProperty("type", out var typeProp)
                ? (typeProp.GetString() ?? string.Empty).Trim()
                : null;
        }
        catch
        {
            return null;
        }
    }
}
