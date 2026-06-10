namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record AnnotatorAnnotationResponse(
    string Id,
    string LabelId,
    string GeometryData,
    bool IsDraft,
    DateTime CreatedAt,
    DateTime UpdatedAt,
    DateTime? SubmittedAt
);
