namespace DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

public sealed record ExportResponse(
    string Id,
    string ProjectId,
    string ProjectName,
    string Format,
    string ExportedByUserId,
    string ExportedByEmail,
    string ExportPath,
    DateTime CreatedAt,
    ExportConfigResponse Config
);
