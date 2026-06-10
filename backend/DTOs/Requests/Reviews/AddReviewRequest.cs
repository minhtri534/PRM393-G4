namespace DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;

public sealed record AddReviewRequest(
    string AnnotationSetId,
    string ReviewerId,
    string Result,
    int Score,
    string? Comment,
    DateTime ReviewedAt
);
