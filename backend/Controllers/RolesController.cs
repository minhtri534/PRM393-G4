using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Roles;
using DataLabellingSupportSystem.Api.DTOs.Responses.Roles;
using DataLabellingSupportSystem.Api.Services.Roles;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/roles")]
[Authorize]
public sealed class RolesController(IRolesService rolesService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ServiceResponse<List<RoleResponse>>>> GetAll()
    {
        var result = await rolesService.GetAllAsync();
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ServiceResponse<RoleResponse>>> Create([FromBody] CreateRoleRequest request)
    {
        var result = await rolesService.CreateAsync(request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("{roleId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ServiceResponse<RoleResponse>>> Update([FromRoute] string roleId, [FromBody] UpdateRoleRequest request)
    {
        var result = await rolesService.UpdateAsync(roleId, request);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("{roleId}")]
    [Authorize(Roles = "Admin")]
    public async Task<ActionResult<ServiceResponse<bool>>> Delete([FromRoute] string roleId)
    {
        var result = await rolesService.DeleteAsync(roleId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }
}
