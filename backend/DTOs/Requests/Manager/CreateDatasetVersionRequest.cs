namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record CreateDatasetVersionRequest(
    string DatasetId,
    string VersionName
);
