namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record AiAssistSuggestResponse(
    string RunId,
    string Provider,
    string Model,
    double ConfidenceThreshold,
    int OriginalWidth,
    int OriginalHeight,
    List<AiAssistSuggestionObject> Objects
);

public sealed record AiAssistSuggestionObject(
    string LabelId,
    double Confidence,
    string GeometryData
);
