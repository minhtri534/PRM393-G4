namespace DataLabellingSupportSystem.Api.DTOs.Responses.Exports;

public sealed record YoloExportResponse(
    List<string> Classes,
    List<YoloLabelFileResponse> Files
);

public sealed record YoloLabelFileResponse(
    string FileName,
    string Content
);
