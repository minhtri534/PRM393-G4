using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.ErrorTypes;
using DataLabellingSupportSystem.Api.Services.LabelingTasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/tasks")]
[Authorize]
public sealed class LabelingTasksController(ILabelingTasksService service) : ControllerBase
{
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var result = await service.GetAll();
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var result = await service.GetLabelingTaskById(id);
        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }

    [HttpGet("submitted")]
    public async Task<IActionResult> GetSubmittedLabelingTasks(string id)
    {
        var result = await service.GetSubmittedLabelingTask();
        return Ok(result);
    }

    [HttpPost]
    public async Task<IActionResult> AddLabelingTask([FromBody] LabelingTask r)
    {
        await service.AddLabelingTask(r);
        return Ok();
    }

    [HttpPut]
    public async Task<IActionResult> UpdateReview([FromBody] LabelingTask r)
    {
        await service.UpdateLabelingTask(r);
        return Ok();
    }

    [HttpDelete]
    public async Task<IActionResult> DeleteErrorType([FromBody] string id)
    {
        await service.DeleteLabelingTask(id);
        return Ok();
    }
}
