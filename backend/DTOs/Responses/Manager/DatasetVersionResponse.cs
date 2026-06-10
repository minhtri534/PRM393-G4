namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record DatasetVersionResponse(
    string Id,
    string DatasetId,
    string VersionName,
    DateTime CreatedAt
);
