namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record AnnotatorTaskItemResponse(
    string TaskId,
    string DataItemId,
    string StorageProvider,
    string ObjectKey,
    int OriginalWidth,
    int OriginalHeight
);
