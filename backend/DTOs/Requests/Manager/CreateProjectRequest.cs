namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record CreateProjectRequest(
    string Name,
    string? Guideline,
    int Status = 0
);
