namespace DataLabellingSupportSystem.Api.Services.AiAssist;

public interface IYoloInferenceClient
{
    Task<YoloDetectResult> DetectAsync(
        byte[] imageBytes,
        string fileName,
        CancellationToken cancellationToken);
}

public sealed record YoloDetectResult(
    string Provider,
    string Model,
    double ConfidenceThreshold,
    List<YoloDetection> Detections
);

public sealed record YoloDetection(
    int ClassId,
    double Confidence,
    double X1,
    double Y1,
    double X2,
    double Y2
);
