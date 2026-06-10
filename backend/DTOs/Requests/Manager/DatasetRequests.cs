namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record CreateDatasetRequest(
    string ProjectId,
    string Name
);

public sealed record UpdateDatasetRequest(
    string Name
);

public sealed record UploadDatasetItemsRequest(
    string DatasetId,
    List<UploadDatasetItemDto> Items
);

public sealed record UploadDatasetItemDto(
    string ObjectKey,
    int OriginalWidth,
    int OriginalHeight,
    string DataType = "Image",
    string? Checksum = null,
    string StorageProvider = "Local"
);

public sealed record ImportDatasetFromExternalRequest(
    string DatasetId,
    string SourceName,
    List<UploadDatasetItemDto> Items
);
