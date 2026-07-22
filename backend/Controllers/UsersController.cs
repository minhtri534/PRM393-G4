using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using DataLabellingSupportSystem.Api.DTOs.Responses.Users;
using DataLabellingSupportSystem.Api.Services.Users;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/users")]
[Authorize]
public sealed class UsersController(IUsersService usersService) : ControllerBase
{
    [HttpGet]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<List<UserResponse>>>> GetAll()
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<List<UserResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.GetAllAsync(actorUserId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("search")]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<List<UserSummaryResponse>>>> Search([FromQuery] string q, [FromQuery] string? role = null)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<UserSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.SearchAsync(userId, q, role);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("me")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> GetMe()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.GetMeAsync(userId);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPut("me")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> UpdateMe([FromBody] UpdateOwnProfileRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.UpdateMeAsync(userId, request);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("me")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteMe()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.DeleteMeAsync(userId);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpGet("{userId}")]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> GetById([FromRoute] string userId)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.GetByIdAsync(actorUserId, userId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPost]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> Create([FromBody] CreateUserRequest request)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.CreateAsync(actorUserId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("{userId}")]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> Update([FromRoute] string userId, [FromBody] UpdateUserRequest request)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.UpdateAsync(actorUserId, userId, request);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("{userId}")]
    [Authorize(Roles = "Admin,Manager")]
    public async Task<ActionResult<ServiceResponse<bool>>> Delete([FromRoute] string userId)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.DeleteAsync(actorUserId, userId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }
}
