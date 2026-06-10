using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.ErrorTypes;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/error_type")]
[Authorize(Roles = "Admin,Reviewer")]
public sealed class ErrorTypeController(IErrorTypesService service) : ControllerBase
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
        var result = await service.GetErrorTypeById(id);
        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> AddReview([FromBody] UpdateErrorTypeRequest r)
    {
        var errorType = new ErrorType
        {
            Id = ObjectId.NewObjectId(),
            Description = r.Description,
            ErrorName = r.ErrorName
        };
        await service.AddErrorType(errorType);
        return Ok();
    }

    [HttpPut]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> UpdateReview([FromBody] UpdateErrorTypeRequest r)
    {
        var errorType = new ErrorType
        {
            Description = r.Description,
            ErrorName = r.ErrorName
        };
        await service.UpdateErrorType(errorType);
        return Ok();
    }

    [HttpDelete]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> DeleteErrorType([FromBody] string id)
    {
        await service.DeleteErrorType(id);
        return Ok();
    }
}
