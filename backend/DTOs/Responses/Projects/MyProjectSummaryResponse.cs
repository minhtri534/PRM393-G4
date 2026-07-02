namespace DataLabellingSupportSystem.Api.DTOs.Responses.Projects;

public sealed record MyProjectSummaryResponse(
    string Id,
    string Name,
    string? Guideline,
    int TodoTaskCount,
    int DoneTaskCount,
    DateTime? LastChatMessageAt,
    string? LastChatMessagePreview
);
