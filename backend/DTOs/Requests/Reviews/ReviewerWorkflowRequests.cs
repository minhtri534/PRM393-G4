namespace DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;

public sealed record ApproveLabeledDataRequest(
    int Score,
    string? Comment);

public sealed record ReturnLabelWithFeedbackRequest(
    string Feedback,
    int Score,
    List<string>? ErrorTypeIds);

public sealed record CreateReviewErrorRecordRequest(
    string ErrorTypeId);

public sealed record UpdateReviewErrorRecordRequest(
    string OldErrorTypeId,
    string NewErrorTypeId);