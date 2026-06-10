using DataLabellingSupportSystem.Api.Services.Reviews;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/reviews")]
[Authorize]
public sealed class ReviewsController(IReviewsService service) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll()
    {
        var result = await service.GetAll();
        return Ok(result);
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(string id)
    {
        var result = await service.GetReviewById(id);
        if (result is null)
        {
            return NotFound();
        }

        return Ok(result);
    }
}
