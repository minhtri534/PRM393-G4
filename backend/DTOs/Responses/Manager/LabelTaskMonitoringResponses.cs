namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record LabelResponse(
    string Id,
    string ProjectId,
    string Name,
    int YoloClassId,
    string? CategoryId,
    string? AnnotationTypeId,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public sealed record LabelCategoryResponse(
    string Id,
    string ProjectId,
    string Name,
    string? Description,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public sealed record AnnotationTypeResponse(
    string Id,
    string ProjectId,
    string Name,
    string? Description,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public sealed record TaskResponse(
    string Id,
    string ProjectId,
    string DataItemId,
    string AnnotatorId,
    string? AssignedByUserId,
    string Status,
    DateTime? AssignedAt,
    DateTime? CompletedAt
);

public sealed record TaskProgressResponse(
    string ProjectId,
    int Total,
    int Assigned,
    int InProgress,
    int Submitted,
    int Completed,
    int Paused,
    int Cancelled,
    int Rework
);

public sealed record TaskHistoryResponse(
    string Id,
    string TaskId,
    string? OldStatus,
    string? NewStatus,
    string ChangedByUserId,
    DateTime ChangedAt
);

public sealed record LabelingProgressOverviewResponse(
    string ProjectId,
    int TotalTasks,
    int CompletedTasks,
    int SubmittedTasks,
    int ActiveTasks
);

public sealed record AnnotatorPerformanceResponse(
    string AnnotatorId,
    string AnnotatorEmail,
    int AssignedTasks,
    int SubmittedTasks,
    int CompletedTasks
);

public sealed record ReviewStatisticsResponse(
    string ProjectId,
    int TotalReviews,
    int ApprovedReviews,
    int RejectedReviews,
    double AverageScore
);

public sealed record InconsistentLabelResponse(
    string AnnotationId,
    string TaskId,
    string LabelId,
    string Issue
);

public sealed record QualityReportResponse(
    LabelingProgressOverviewResponse Progress,
    ReviewStatisticsResponse ReviewStats,
    int InconsistentLabelsCount
);

public sealed record ExportValidationResponse(
    string ProjectId,
    int SubmittedAnnotationSets,
    int ReviewedAnnotationSets,
    bool IsValid
);

public sealed record ExportDownloadInfoResponse(
    string ExportId,
    string StorageProvider,
    string ObjectKey,
    string FileName
);
