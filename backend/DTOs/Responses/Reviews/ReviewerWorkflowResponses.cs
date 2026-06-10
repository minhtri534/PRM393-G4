namespace DataLabellingSupportSystem.Api.DTOs.Responses.Reviews;

public sealed record ReviewerSubmittedTaskResponse(
    string Id,
    string ProjectId,
    string ProjectName,
    string AnnotatorId,
    string AnnotatorName,
    string AnnotationSetId,
    DateTime SubmittedAt,
    int AnnotationCount,
    string Status = "Submitted");

public sealed record ReviewerAnnotationItemResponse(
    string AnnotationId,
    string LabelId,
    string LabelName,
    string AnnotationType,
    string GeometryData);

public sealed record ReviewerLabeledDataResponse(
    string TaskId,
    string AnnotationSetId,
    string? Guideline,
    string StorageProvider,
    string ObjectKey,
    List<ReviewerAnnotationItemResponse> Annotations);

public sealed record GuidelineComparisonResponse(
    string TaskId,
    string AnnotationSetId,
    bool HasGuideline,
    bool IsAligned,
    List<string> Notes);

public sealed record LabelConsistencyValidationResponse(
    string TaskId,
    string AnnotationSetId,
    int TotalAnnotations,
    bool IsConsistent,
    List<string> Issues);

public sealed record ReviewerErrorTypeResponse(
    string ErrorTypeId,
    string ErrorName,
    string? Description);

public sealed record ReviewerErrorStatisticsResponse(
    int TotalReviews,
    int ApprovedReviews,
    int RejectedReviews,
    int TotalErrorRecords,
    Dictionary<string, int> ErrorTypeCounts);