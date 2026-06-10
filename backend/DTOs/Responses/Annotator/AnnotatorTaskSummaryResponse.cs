namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record AnnotatorTaskSummaryResponse(
    string Id,
    string ProjectId,
    string DataItemId,
    string Status,
    DateTime? AssignedAt,
    DateTime? CompletedAt
);
