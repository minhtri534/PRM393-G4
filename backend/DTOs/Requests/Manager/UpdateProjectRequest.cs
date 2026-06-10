namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record UpdateProjectRequest(
    string Name,
    string? Guideline,
    int Status
);
