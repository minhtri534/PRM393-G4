namespace DataLabellingSupportSystem.Api.Configurations;

public sealed class AiAssistOptions
{
    public bool Enabled { get; init; } = false;

    // Currently supported provider: HttpYolo
    public string Provider { get; init; } = "HttpYolo";

    // Base address of the inference service (e.g. http://localhost:8001)
    public string BaseUrl { get; init; } = "http://localhost:8001";

    // Relative path for detection endpoint
    public string DetectPath { get; init; } = "/detect";

    // A human-readable model identifier (returned in response metadata)
    public string Model { get; init; } = "yolov8n.pt";

    public double ConfidenceThreshold { get; init; } = 0.25;

    // Safety guard to avoid reading extremely large files into memory
    public long MaxImageBytes { get; init; } = 10 * 1024 * 1024;

    public int TimeoutSeconds { get; init; } = 60;

    // Optional API key header value for the inference service
    public string? ApiKey { get; init; }
}
