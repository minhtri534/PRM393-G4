namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record ExportConfigResponse(
    string LabelFormat,
    string IncludeFields,
    string Filters
);
