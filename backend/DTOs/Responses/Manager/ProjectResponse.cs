namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record ProjectResponse(
    string Id,
    string Name,
    string? Guideline,
    int Status,
    DateTime CreatedAt,
    DateTime UpdatedAt
);
