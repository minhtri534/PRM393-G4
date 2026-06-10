namespace DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;

public sealed record UpdateReviewRequest(
    string Id,
    string Result,
    int Score,
    string? Comment,
    DateTime ReviewedAt
);
