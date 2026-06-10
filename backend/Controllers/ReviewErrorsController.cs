using DataLabellingSupportSystem.Api.Services.ReviewErrors;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/review_errors")]
[Authorize]
public sealed class ReviewErrorsController(IReviewErrorsService service) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = "Admin")]
    public async Task<IActionResult> GetAll()
    {
        var result = await service.GetAll();
        return Ok(result);
    }
}
