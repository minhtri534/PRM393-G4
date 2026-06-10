namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record DatasetResponse(
    string Id,
    string ProjectId,
    string ProjectName,
    string Name,
    int TotalItems,
    DateTime CreatedAt,
    DateTime UpdatedAt
);

public sealed record DataItemResponse(
    string Id,
    string DatasetId,
    string ObjectKey,
    string DataType,
    int OriginalWidth,
    int OriginalHeight,
    string Status,
    DateTime CreatedAt
);

public sealed record UploadDatasetItemsResponse(
    string DatasetId,
    int CreatedCount
);
