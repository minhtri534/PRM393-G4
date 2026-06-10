namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record LabelResponse(
    string Id,
    string Name,
    int YoloClassId
);
