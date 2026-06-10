using System.Net.Http.Headers;
using System.Text.Json;
using DataLabellingSupportSystem.Api.Configurations;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.AiAssist;

public sealed class HttpYoloInferenceClient(HttpClient httpClient, IOptions<AiAssistOptions> options, ILogger<HttpYoloInferenceClient> logger)
    : IYoloInferenceClient
{
    public async Task<YoloDetectResult> DetectAsync(byte[] imageBytes, string fileName, CancellationToken cancellationToken)
    {
        var opt = options.Value;

        if (!opt.Enabled)
        {
            return new YoloDetectResult(
                Provider: "Disabled",
                Model: opt.Model,
                ConfidenceThreshold: opt.ConfidenceThreshold,
                Detections: []);
        }

        if (!string.Equals(opt.Provider, "HttpYolo", StringComparison.OrdinalIgnoreCase))
        {
            throw new InvalidOperationException($"Unsupported AiAssist Provider: {opt.Provider}");
        }

        using var content = new MultipartFormDataContent();
        var fileContent = new ByteArrayContent(imageBytes);
        fileContent.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");
        content.Add(fileContent, "file", string.IsNullOrWhiteSpace(fileName) ? "image" : fileName);

        var url = opt.DetectPath;
        if (!url.Contains('?', StringComparison.Ordinal))
        {
            url += $"?conf={opt.ConfidenceThreshold.ToString(System.Globalization.CultureInfo.InvariantCulture)}";
        }

        using var request = new HttpRequestMessage(HttpMethod.Post, url)
        {
            Content = content
        };

        if (!string.IsNullOrWhiteSpace(opt.ApiKey))
        {
            request.Headers.TryAddWithoutValidation("X-Api-Key", opt.ApiKey);
        }

        using var response = await httpClient.SendAsync(request, cancellationToken);
        var responseBody = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            logger.LogWarning("YOLO inference failed. Status: {Status}. Body: {Body}", (int)response.StatusCode, responseBody);
            throw new InvalidOperationException($"YOLO inference failed with HTTP {(int)response.StatusCode}");
        }

        return ParseResult(responseBody, opt);
    }

    private static YoloDetectResult ParseResult(string json, AiAssistOptions opt)
    {
        using var doc = JsonDocument.Parse(json);
        var root = doc.RootElement;

        var provider = root.TryGetProperty("provider", out var providerProp) ? providerProp.GetString() : null;
        var model = root.TryGetProperty("model", out var modelProp) ? modelProp.GetString() : null;
        var conf = root.TryGetProperty("confidenceThreshold", out var confProp) ? confProp.GetDouble() : opt.ConfidenceThreshold;

        var detections = new List<YoloDetection>();

        if (root.TryGetProperty("detections", out var detArr) && detArr.ValueKind == JsonValueKind.Array)
        {
            foreach (var det in detArr.EnumerateArray())
            {
                if (!det.TryGetProperty("classId", out var classIdProp) || classIdProp.ValueKind != JsonValueKind.Number)
                {
                    continue;
                }

                var classId = classIdProp.GetInt32();
                var confidence = det.TryGetProperty("confidence", out var cProp) && cProp.ValueKind == JsonValueKind.Number
                    ? cProp.GetDouble()
                    : 0d;

                if (!det.TryGetProperty("bbox", out var bbox) || bbox.ValueKind != JsonValueKind.Object)
                {
                    continue;
                }

                if (!bbox.TryGetProperty("x1", out var x1Prop) ||
                    !bbox.TryGetProperty("y1", out var y1Prop) ||
                    !bbox.TryGetProperty("x2", out var x2Prop) ||
                    !bbox.TryGetProperty("y2", out var y2Prop))
                {
                    continue;
                }

                detections.Add(new YoloDetection(
                    ClassId: classId,
                    Confidence: confidence,
                    X1: x1Prop.GetDouble(),
                    Y1: y1Prop.GetDouble(),
                    X2: x2Prop.GetDouble(),
                    Y2: y2Prop.GetDouble()));
            }
        }

        return new YoloDetectResult(
            Provider: string.IsNullOrWhiteSpace(provider) ? "HttpYolo" : provider!,
            Model: string.IsNullOrWhiteSpace(model) ? opt.Model : model!,
            ConfidenceThreshold: conf,
            Detections: detections);
    }
}
