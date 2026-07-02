using System.Text.Json;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using DataLabellingSupportSystem.Api.DTOs.Responses.Reviews;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Services.Reviews;

public sealed class ReviewerWorkflowService(AppDbContext dbContext) : IReviewerWorkflowService
{
    public async Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string reviewerUserId)
    {
        var reviewerId = (reviewerUserId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(reviewerId))
        {
            return ServiceResponse<List<MyProjectSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var isAdmin = await IsSystemAdminAsync(reviewerId);
        List<string> accessibleProjectIds;
        if (isAdmin)
        {
            accessibleProjectIds = await dbContext.Projects
                .AsNoTracking()
                .Select(x => x.Id)
                .ToListAsync();
        }
        else
        {
            accessibleProjectIds = await GetReviewerProjectIdsAsync(reviewerId);
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

        var submittedTasksResult = await GetSubmittedTasksAsync(reviewerId);
        var pendingByProject = (submittedTasksResult.Data ?? [])
            .GroupBy(x => x.ProjectId)
            .ToDictionary(g => g.Key, g => g.Count(), StringComparer.Ordinal);

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
            var pending = pendingByProject.TryGetValue(project.Id, out var count) ? count : 0;
            var last = lastMessages.FirstOrDefault(x => x.ProjectId == project.Id);
            var preview = BuildChatPreview(last?.MessageType, last?.Content, last?.AttachmentFileName);

            return new MyProjectSummaryResponse(
                project.Id,
                project.Name,
                project.Guideline,
                pending,
                0,
                last?.CreatedAt,
                preview);
        }).ToList();

        return ServiceResponse<List<MyProjectSummaryResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<List<ReviewerSubmittedTaskResponse>>> GetSubmittedTasksAsync(string reviewerUserId, string? projectId = null)
    {
        var reviewerId = (reviewerUserId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(reviewerId))
        {
            return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var isAdmin = await IsSystemAdminAsync(reviewerId);
        var accessibleReviewerProjectIds = isAdmin
            ? []
            : await GetReviewerProjectIdsAsync(reviewerId);

        if (!isAdmin && accessibleReviewerProjectIds.Count == 0)
        {
            return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Success([], "OK");
        }

        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        if (!isAdmin && !string.IsNullOrWhiteSpace(normalizedProjectId)
            && !accessibleReviewerProjectIds.Contains(normalizedProjectId))
        {
            return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Failure(ErrorMessages.Forbidden, ["You do not have access to this project"]);
        }

        var eligibleTasks = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => isAdmin || accessibleReviewerProjectIds.Contains(x.ProjectId))
            .Select(x => new 
            { 
                x.Id, 
                x.ProjectId, 
                ProjectName = x.Project != null ? x.Project.Name : string.Empty,
                x.DataItemId, 
                x.AnnotatorId,
                AnnotatorName = x.Annotator != null ? x.Annotator.FullName : string.Empty
            })
            .ToListAsync();

        if (!string.IsNullOrWhiteSpace(normalizedProjectId))
        {
            eligibleTasks = eligibleTasks
                .Where(x => x.ProjectId == normalizedProjectId)
                .ToList();
        }

        if (eligibleTasks.Count == 0)
        {
            return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Success([], "OK");
        }

        var eligibleTaskIds = eligibleTasks.Select(x => x.Id).ToList();

        var submittedSets = await dbContext.AnnotationSets
            .AsNoTracking()
            .Where(x => x.Status == "Submitted" && eligibleTaskIds.Contains(x.TaskId))
            .Select(x => new
            {
                x.Id,
                x.TaskId,
                x.CreatedAt
            })
            .ToListAsync();

        if (submittedSets.Count == 0)
        {
            return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Success([], "OK");
        }

        var tasks = eligibleTasks
            .GroupBy(x => x.Id)
            .ToDictionary(x => x.Key, x => x.First(), StringComparer.Ordinal);

        var submittedSetIds = submittedSets.Select(s => s.Id).ToList();

        var counts = await dbContext.Annotations
            .AsNoTracking()
            .Where(x => submittedSetIds.Contains(x.AnnotationSetId))
            .GroupBy(x => x.AnnotationSetId)
            .Select(g => new { AnnotationSetId = g.Key, Count = g.Count() })
            .ToListAsync();

        var annotationCounts = counts.ToDictionary(x => x.AnnotationSetId, x => x.Count, StringComparer.Ordinal);

        var reviewsBySetId = await dbContext.Reviews
            .AsNoTracking()
            .Where(x => submittedSetIds.Contains(x.AnnotationSetId))
            .Select(x => x.AnnotationSetId)
            .Distinct()
            .ToListAsync();

        var reviewedSetIds = reviewsBySetId.ToHashSet(StringComparer.Ordinal);

        var response = submittedSets
            .Where(x => !reviewedSetIds.Contains(x.Id))
            .Where(x => tasks.ContainsKey(x.TaskId))
            .Select(x =>
            {
                var task = tasks[x.TaskId];
                return new ReviewerSubmittedTaskResponse(
                    task.Id,
                    task.ProjectId,
                    task.ProjectName,
                    task.AnnotatorId,
                    task.AnnotatorName,
                    x.Id,
                    x.CreatedAt,
                    annotationCounts.TryGetValue(x.Id, out var count) ? count : 0,
                    "Submitted");
            })
            .OrderByDescending(x => x.SubmittedAt)
            .ToList();

        return ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Success(response, "OK");
    }

    public async Task<ServiceResponse<ReviewerLabeledDataResponse>> OpenLabeledDataAsync(string reviewerUserId, string taskId)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<ReviewerLabeledDataResponse>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var setResult = await GetLatestSubmittedAnnotationSetAsync(taskId);
        if (!setResult.IsSuccess || setResult.Data is null)
        {
            return ServiceResponse<ReviewerLabeledDataResponse>.Failure(setResult.Message, setResult.Errors);
        }

        var set = setResult.Data;

        var taskData = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == set.TaskId)
            .Select(x => new
            {
                x.Id,
                Guideline = x.Project != null ? x.Project.Guideline : null,
                StorageProvider = x.DataItem != null ? x.DataItem.StorageProvider : string.Empty,
                ObjectKey = x.DataItem != null ? x.DataItem.ObjectKey : string.Empty
            })
            .FirstOrDefaultAsync();

        if (taskData is null)
        {
            return ServiceResponse<ReviewerLabeledDataResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var access = await EnsureReviewerTaskAccessAsync(reviewerUserId, taskData.Id);
        if (access is not null)
        {
            return ServiceResponse<ReviewerLabeledDataResponse>.Failure(access.Message, access.Errors);
        }

        var annotations = await dbContext.Annotations
            .AsNoTracking()
            .Where(x => x.AnnotationSetId == set.Id)
            .Select(x => new ReviewerAnnotationItemResponse(
                x.Id,
                x.LabelId,
                x.Label != null ? x.Label.Name : string.Empty,
                x.AnnotationType,
                x.GeometryData))
            .ToListAsync();

        return ServiceResponse<ReviewerLabeledDataResponse>.Success(
            new ReviewerLabeledDataResponse(
                taskData.Id,
                set.Id,
                taskData.Guideline,
                taskData.StorageProvider,
                taskData.ObjectKey,
                annotations),
            "OK");
    }

    public async Task<ServiceResponse<TaskDataItemStorageResponse>> GetTaskDataItemStorageAsync(string reviewerUserId, string taskId, CancellationToken cancellationToken)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var access = await EnsureReviewerTaskAccessAsync(reviewerUserId, taskId);
        if (access is not null)
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(access.Message, access.Errors);
        }

        var item = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == taskId)
            .Select(x => new
            {
                StorageProvider = x.DataItem != null ? x.DataItem.StorageProvider : null,
                ObjectKey = x.DataItem != null ? x.DataItem.ObjectKey : null
            })
            .FirstOrDefaultAsync(cancellationToken);

        if (item is null || string.IsNullOrWhiteSpace(item.StorageProvider) || string.IsNullOrWhiteSpace(item.ObjectKey))
        {
            return ServiceResponse<TaskDataItemStorageResponse>.Failure(ErrorMessages.NotFound, ["Data item not found"]);
        }

        return ServiceResponse<TaskDataItemStorageResponse>.Success(
            new TaskDataItemStorageResponse(item.StorageProvider, item.ObjectKey),
            "OK");
    }

    public async Task<ServiceResponse<GuidelineComparisonResponse>> CompareWithGuidelineAsync(string reviewerUserId, string taskId)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<GuidelineComparisonResponse>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var openResult = await OpenLabeledDataAsync(reviewerUserId, taskId);
        if (!openResult.IsSuccess || openResult.Data is null)
        {
            return ServiceResponse<GuidelineComparisonResponse>.Failure(openResult.Message, openResult.Errors);
        }

        var data = openResult.Data;
        var notes = new List<string>();

        if (string.IsNullOrWhiteSpace(data.Guideline))
        {
            notes.Add("Project guideline is empty");
        }

        if (data.Annotations.Count == 0)
        {
            notes.Add("No annotations found in submitted data");
        }

        var isAligned = notes.Count == 0;

        return ServiceResponse<GuidelineComparisonResponse>.Success(
            new GuidelineComparisonResponse(
                data.TaskId,
                data.AnnotationSetId,
                HasGuideline: !string.IsNullOrWhiteSpace(data.Guideline),
                IsAligned: isAligned,
                notes),
            "OK");
    }

    public async Task<ServiceResponse<LabelConsistencyValidationResponse>> ValidateLabelConsistencyAsync(string reviewerUserId, string taskId)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<LabelConsistencyValidationResponse>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var setResult = await GetLatestSubmittedAnnotationSetAsync(taskId);
        if (!setResult.IsSuccess || setResult.Data is null)
        {
            return ServiceResponse<LabelConsistencyValidationResponse>.Failure(setResult.Message, setResult.Errors);
        }

        var set = setResult.Data;

        var task = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == set.TaskId)
            .Select(x => new { x.Id, x.ProjectId })
            .FirstOrDefaultAsync();

        if (task is null)
        {
            return ServiceResponse<LabelConsistencyValidationResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var access = await EnsureReviewerProjectAccessAsync(reviewerUserId, task.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<LabelConsistencyValidationResponse>.Failure(access.Message, access.Errors);
        }

        var labels = await dbContext.Labels
            .AsNoTracking()
            .Where(x => x.ProjectId == task.ProjectId)
            .Select(x => new { x.Id, AnnotationTypeName = x.AnnotationType != null ? x.AnnotationType.Name : null })
            .ToDictionaryAsync(x => x.Id, x => x.AnnotationTypeName ?? string.Empty);

        var annotations = await dbContext.Annotations
            .AsNoTracking()
            .Where(x => x.AnnotationSetId == set.Id)
            .Select(x => new { x.Id, x.LabelId, x.AnnotationType, x.GeometryData })
            .ToListAsync();

        var issues = new List<string>();

        foreach (var annotation in annotations)
        {
            if (!labels.ContainsKey(annotation.LabelId))
            {
                issues.Add($"Annotation {annotation.Id}: label does not belong to task project");
                continue;
            }

            if (!IsValidGeometryJson(annotation.GeometryData))
            {
                issues.Add($"Annotation {annotation.Id}: invalid geometry json");
            }

            var expectedType = labels[annotation.LabelId];
            if (!string.IsNullOrWhiteSpace(expectedType) && !string.Equals(expectedType, annotation.AnnotationType, StringComparison.OrdinalIgnoreCase))
            {
                issues.Add($"Annotation {annotation.Id}: annotation type mismatch (expected '{expectedType}', actual '{annotation.AnnotationType}')");
            }
        }

        return ServiceResponse<LabelConsistencyValidationResponse>.Success(
            new LabelConsistencyValidationResponse(
                task.Id,
                set.Id,
                annotations.Count,
                IsConsistent: issues.Count == 0,
                issues),
            "OK");
    }

    public async Task<ServiceResponse<bool>> ApproveLabeledDataAsync(string reviewerUserId, string taskId, ApproveLabeledDataRequest request)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var setResult = await GetLatestSubmittedAnnotationSetAsync(taskId);
        if (!setResult.IsSuccess || setResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(setResult.Message, setResult.Errors);
        }

        var set = setResult.Data;
        var access = await EnsureReviewerTaskAccessAsync(reviewerUserId, set.TaskId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var review = await GetOrCreateReviewAsync(set.Id, reviewerUserId);

        review.Result = "Approved";
        review.Score = request.Score;
        review.Comment = string.IsNullOrWhiteSpace(request.Comment) ? null : request.Comment.Trim();
        review.ReviewedAt = DlssTime.VietnamNow;

        var reviewErrors = await dbContext.ReviewErrors
            .Where(x => x.ReviewId == review.Id)
            .ToListAsync();
        if (reviewErrors.Count > 0)
        {
            dbContext.ReviewErrors.RemoveRange(reviewErrors);
        }

        await SetTaskStatusWithHistoryAsync(set.TaskId, "Completed", reviewerUserId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Approved");
    }

    public async Task<ServiceResponse<bool>> ReturnLabelWithFeedbackAsync(string reviewerUserId, string taskId, ReturnLabelWithFeedbackRequest request)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var feedback = (request.Feedback ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(feedback))
        {
            return ServiceResponse<bool>.Failure("Invalid feedback", ["Feedback is required"]);
        }

        var setResult = await GetLatestSubmittedAnnotationSetAsync(taskId);
        if (!setResult.IsSuccess || setResult.Data is null)
        {
            return ServiceResponse<bool>.Failure(setResult.Message, setResult.Errors);
        }

        var set = setResult.Data;
        var access = await EnsureReviewerTaskAccessAsync(reviewerUserId, set.TaskId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var review = await GetOrCreateReviewAsync(set.Id, reviewerUserId);

        review.Result = "Rejected";
        review.Score = request.Score;
        review.Comment = feedback;
        review.ReviewedAt = DlssTime.VietnamNow;

        var selectedErrorTypeIds = (request.ErrorTypeIds ?? [])
            .Where(x => !string.IsNullOrWhiteSpace(x))
            .Select(x => x.Trim())
            .Distinct(StringComparer.Ordinal)
            .ToList();

        if (selectedErrorTypeIds.Count > 0)
        {
            var validErrorTypeIds = await dbContext.ErrorTypes
                .AsNoTracking()
                .Where(x => selectedErrorTypeIds.Contains(x.Id))
                .Select(x => x.Id)
                .ToListAsync();

            var invalid = selectedErrorTypeIds.Except(validErrorTypeIds, StringComparer.Ordinal).ToList();
            if (invalid.Count > 0)
            {
                return ServiceResponse<bool>.Failure("Invalid error type", invalid.Select(x => $"Error type not found: {x}").ToList());
            }
        }

        var currentErrors = await dbContext.ReviewErrors
            .Where(x => x.ReviewId == review.Id)
            .ToListAsync();

        dbContext.ReviewErrors.RemoveRange(currentErrors);

        foreach (var errorTypeId in selectedErrorTypeIds)
        {
            dbContext.ReviewErrors.Add(new ReviewError
            {
                ReviewId = review.Id,
                ErrorTypeId = errorTypeId
            });
        }

        await SetTaskStatusWithHistoryAsync(set.TaskId, "Rework", reviewerUserId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Returned with feedback");
    }

    public async Task<ServiceResponse<List<ReviewerErrorTypeResponse>>> GetErrorTypesAsync(string reviewerUserId)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<List<ReviewerErrorTypeResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var items = await dbContext.ErrorTypes
            .AsNoTracking()
            .OrderBy(x => x.ErrorName)
            .Select(x => new ReviewerErrorTypeResponse(x.Id, x.ErrorName, x.Description))
            .ToListAsync();

        return ServiceResponse<List<ReviewerErrorTypeResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<bool>> CreateErrorRecordAsync(string reviewerUserId, string reviewId, CreateReviewErrorRecordRequest request)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var rid = (reviewId ?? string.Empty).Trim();
        var errorTypeId = (request.ErrorTypeId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(rid) || string.IsNullOrWhiteSpace(errorTypeId))
        {
            return ServiceResponse<bool>.Failure("Invalid request", ["Review id and error type id are required"]);
        }

        var review = await dbContext.Reviews
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == rid && x.ReviewerId == reviewerUserId);

        if (review is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this review"]);
        }

        var errorTypeExists = await dbContext.ErrorTypes
            .AsNoTracking()
            .AnyAsync(x => x.Id == errorTypeId);

        if (!errorTypeExists)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Error type not found"]);
        }

        var exists = await dbContext.ReviewErrors
            .AsNoTracking()
            .AnyAsync(x => x.ReviewId == rid && x.ErrorTypeId == errorTypeId);

        if (exists)
        {
            return ServiceResponse<bool>.Failure("Error record already exists", ["Duplicate review error record"]);
        }

        dbContext.ReviewErrors.Add(new ReviewError
        {
            ReviewId = rid,
            ErrorTypeId = errorTypeId
        });

        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Created");
    }

    public async Task<ServiceResponse<bool>> UpdateErrorRecordAsync(string reviewerUserId, string reviewId, UpdateReviewErrorRecordRequest request)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var rid = (reviewId ?? string.Empty).Trim();
        var oldErrorTypeId = (request.OldErrorTypeId ?? string.Empty).Trim();
        var newErrorTypeId = (request.NewErrorTypeId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(rid) || string.IsNullOrWhiteSpace(oldErrorTypeId) || string.IsNullOrWhiteSpace(newErrorTypeId))
        {
            return ServiceResponse<bool>.Failure("Invalid request", ["Review id, old error type id and new error type id are required"]);
        }

        var review = await dbContext.Reviews
            .AsNoTracking()
            .FirstOrDefaultAsync(x => x.Id == rid && x.ReviewerId == reviewerUserId);

        if (review is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this review"]);
        }

        var existingRecord = await dbContext.ReviewErrors
            .FirstOrDefaultAsync(x => x.ReviewId == rid && x.ErrorTypeId == oldErrorTypeId);

        if (existingRecord is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Existing error record not found"]);
        }

        var newTypeExists = await dbContext.ErrorTypes
            .AsNoTracking()
            .AnyAsync(x => x.Id == newErrorTypeId);

        if (!newTypeExists)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["New error type not found"]);
        }

        var duplicate = await dbContext.ReviewErrors
            .AsNoTracking()
            .AnyAsync(x => x.ReviewId == rid && x.ErrorTypeId == newErrorTypeId);

        if (duplicate)
        {
            return ServiceResponse<bool>.Failure("Error record already exists", ["Target error type already linked to this review"]);
        }

        dbContext.ReviewErrors.Remove(existingRecord);
        dbContext.ReviewErrors.Add(new ReviewError
        {
            ReviewId = rid,
            ErrorTypeId = newErrorTypeId
        });

        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Updated");
    }

    public async Task<ServiceResponse<ReviewerErrorStatisticsResponse>> GetErrorStatisticsAsync(string reviewerUserId, string? projectId)
    {
        if (!IsValidUserId(reviewerUserId))
        {
            return ServiceResponse<ReviewerErrorStatisticsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        var pid = (projectId ?? string.Empty).Trim();

        var query = dbContext.Reviews
            .AsNoTracking()
            .Where(x => x.ReviewerId == reviewerUserId)
            .AsQueryable();

        if (!string.IsNullOrWhiteSpace(pid))
        {
            query = query.Where(x => x.AnnotationSet != null && x.AnnotationSet.Task != null && x.AnnotationSet.Task.ProjectId == pid);
        }

        var reviews = await query
            .Select(x => new { x.Id, x.Result })
            .ToListAsync();

        var reviewIds = reviews.Select(x => x.Id).ToList();
        var errorRecords = await dbContext.ReviewErrors
            .AsNoTracking()
            .Where(x => reviewIds.Contains(x.ReviewId))
            .Select(x => new { x.ErrorTypeId, Name = x.ErrorType != null ? x.ErrorType.ErrorName : x.ErrorTypeId })
            .ToListAsync();

        var grouped = errorRecords
            .GroupBy(x => x.Name)
            .ToDictionary(x => x.Key, x => x.Count(), StringComparer.Ordinal);

        var response = new ReviewerErrorStatisticsResponse(
            TotalReviews: reviews.Count,
            ApprovedReviews: reviews.Count(x => string.Equals(x.Result, "Approved", StringComparison.OrdinalIgnoreCase)),
            RejectedReviews: reviews.Count(x => string.Equals(x.Result, "Rejected", StringComparison.OrdinalIgnoreCase)),
            TotalErrorRecords: errorRecords.Count,
            ErrorTypeCounts: grouped);

        return ServiceResponse<ReviewerErrorStatisticsResponse>.Success(response, "OK");
    }

    private async Task<ServiceResponse<AnnotationSet>> GetLatestSubmittedAnnotationSetAsync(string taskId)
    {
        var tid = (taskId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(tid))
        {
            return ServiceResponse<AnnotationSet>.Failure("Invalid task", ["Task id is required"]);
        }

        var taskExists = await dbContext.LabelingTasks
            .AsNoTracking()
            .AnyAsync(x => x.Id == tid);

        if (!taskExists)
        {
            return ServiceResponse<AnnotationSet>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var set = await dbContext.AnnotationSets
            .AsNoTracking()
            .Where(x => x.TaskId == tid && x.Status == "Submitted")
            .OrderByDescending(x => x.CreatedAt)
            .FirstOrDefaultAsync();

        if (set is null)
        {
            return ServiceResponse<AnnotationSet>.Failure(ErrorMessages.NotFound, ["No submitted annotations found for this task"]);
        }

        return ServiceResponse<AnnotationSet>.Success(set, "OK");
    }

    private async Task<Review> GetOrCreateReviewAsync(string annotationSetId, string reviewerUserId)
    {
        var review = await dbContext.Reviews
            .FirstOrDefaultAsync(x => x.AnnotationSetId == annotationSetId && x.ReviewerId == reviewerUserId);

        if (review is not null)
        {
            return review;
        }

        review = new Review
        {
            Id = ObjectId.NewObjectId(),
            AnnotationSetId = annotationSetId,
            ReviewerId = reviewerUserId,
            Result = "Pending",
            Score = 0,
            ReviewedAt = DlssTime.VietnamNow
        };

        dbContext.Reviews.Add(review);
        return review;
    }

    private async Task SetTaskStatusWithHistoryAsync(string taskId, string nextStatus, string changedByUserId)
    {
        var task = await dbContext.LabelingTasks
            .FirstOrDefaultAsync(x => x.Id == taskId);

        if (task is null)
        {
            return;
        }

        var oldStatus = task.Status;
        task.Status = nextStatus;

        if (string.Equals(nextStatus, "Completed", StringComparison.OrdinalIgnoreCase))
        {
            task.CompletedAt = DlssTime.VietnamNow;
        }

        if (!string.Equals(oldStatus, task.Status, StringComparison.Ordinal))
        {
            dbContext.TaskHistories.Add(new TaskHistory
            {
                TaskId = task.Id,
                OldStatus = oldStatus,
                NewStatus = task.Status,
                ChangedByUserId = changedByUserId
            });
        }
    }

    private static bool IsValidUserId(string? userId)
        => !string.IsNullOrWhiteSpace((userId ?? string.Empty).Trim());

    private async Task<ServiceResponse<bool>?> EnsureReviewerTaskAccessAsync(string reviewerUserId, string taskId)
    {
        var tid = (taskId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(tid))
        {
            return ServiceResponse<bool>.Failure("Invalid task", ["Task id is required"]);
        }

        var projectId = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == tid)
            .Select(x => x.ProjectId)
            .FirstOrDefaultAsync();

        if (string.IsNullOrWhiteSpace(projectId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        return await EnsureReviewerProjectAccessAsync(reviewerUserId, projectId);
    }

    private async Task<ServiceResponse<bool>?> EnsureReviewerProjectAccessAsync(string reviewerUserId, string projectId)
    {
        var uid = (reviewerUserId ?? string.Empty).Trim();
        var pid = (projectId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(uid))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing reviewer user id"]);
        }

        if (string.IsNullOrWhiteSpace(pid))
        {
            return ServiceResponse<bool>.Failure("Invalid project", ["Project id is required"]);
        }

        if (await IsSystemAdminAsync(uid))
        {
            return null;
        }

        var hasAccess = await dbContext.UserProjectRoles
            .AsNoTracking()
            .AnyAsync(x =>
                x.UserId == uid
                && x.ProjectId == pid
                 && x.Role != null
                && x.Role.Name == "Reviewer");

        if (hasAccess)
        {
            return null;
        }

        return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this task project"]);
    }

    private async Task<List<string>> GetReviewerProjectIdsAsync(string reviewerUserId)
    {
        return await dbContext.UserProjectRoles
            .AsNoTracking()
            .Where(x =>
                x.UserId == reviewerUserId
                && x.Role != null
                && x.Role.Name == "Reviewer")
            .Select(x => x.ProjectId)
            .Distinct()
            .ToListAsync();
    }

    private static string? BuildChatPreview(string? messageType, string? content, string? fileName)
    {
        var type = (messageType ?? "text").Trim().ToLowerInvariant();
        return type switch
        {
            "image" => "📷 Image",
            "file" => string.IsNullOrWhiteSpace(fileName) ? "📎 File" : $"📎 {fileName.Trim()}",
            _ => string.IsNullOrWhiteSpace(content) ? null : content.Trim()
        };
    }

    private async Task<bool> IsSystemAdminAsync(string userId)
    {
        var uid = (userId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(uid))
        {
            return false;
        }

        var roleName = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == uid)
            .Select(x => x.Role != null ? x.Role.Name : string.Empty)
            .FirstOrDefaultAsync();

        return roleName == "Admin";
    }

    private static bool IsValidGeometryJson(string geometryData)
    {
        if (string.IsNullOrWhiteSpace(geometryData))
        {
            return false;
        }

        try
        {
            using var doc = JsonDocument.Parse(geometryData);
            return doc.RootElement.ValueKind == JsonValueKind.Object;
        }
        catch
        {
            return false;
        }
    }
}