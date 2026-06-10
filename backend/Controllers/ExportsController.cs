using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Responses.Exports;
using DataLabellingSupportSystem.Api.Services.Exports;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/exports")]
[Authorize(Roles = "Admin,Manager")]
public sealed class ExportsController(IExportService exportService) : ControllerBase
{
    [HttpGet("yolo/tasks/{taskId}")]
    public async Task<ActionResult<ServiceResponse<YoloExportResponse>>> ExportYoloForTask([FromRoute] string taskId)
    {
        var result = await exportService.ExportYoloForTaskAsync(taskId);
        return this.ToOkOrBadRequest(result);
    }
}
