using System.Text.Json;

namespace DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;

public sealed record RejectTaskRequest(string? Reason);

public sealed record CreateTaskAnnotationRequest(
    string LabelId,
    JsonElement GeometryData,
    string? PredictionId = null
);

public sealed record UpdateTaskAnnotationRequest(
    string LabelId,
    JsonElement GeometryData,
    string? PredictionId = null
);

public sealed record AddReviewerCommentRequest(string Comment);

public sealed record RejectAiSuggestionRequest(string? Reason);
