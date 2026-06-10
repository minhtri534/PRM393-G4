using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Responses.Exports;

namespace DataLabellingSupportSystem.Api.Services.Exports;

public interface IExportService
{
    Task<ServiceResponse<YoloExportResponse>> ExportYoloForTaskAsync(string taskId);
}
