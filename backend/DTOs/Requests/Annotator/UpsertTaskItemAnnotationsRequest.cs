using System.Text.Json;

namespace DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;

public sealed record UpsertTaskItemAnnotationsRequest(
    List<UpsertAnnotationObject> Objects,
    string? PredictionId = null);

public sealed record UpsertAnnotationObject(
    string LabelId,
    JsonElement GeometryData
);
