namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record ProjectGuidelineResponse(
    string ProjectId,
    string? Guideline
);
