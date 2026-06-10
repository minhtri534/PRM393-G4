using System.Text.Json.Serialization;

namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record CreateExportRequest(
    [property: JsonPropertyName("projectId")] string ProjectId,
    [property: JsonPropertyName("format")] string Format,
    [property: JsonPropertyName("exportPath")] string ExportPath,
    [property: JsonPropertyName("labelFormat")] string LabelFormat,
    [property: JsonPropertyName("includeFields")] string[]? IncludeFields,
    [property: JsonPropertyName("filters")] Dictionary<string, string>? Filters
);
