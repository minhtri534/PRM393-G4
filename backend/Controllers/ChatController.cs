using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Chat;
using DataLabellingSupportSystem.Api.DTOs.Responses.Chat;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using DataLabellingSupportSystem.Api.Services.Chat;
using DataLabellingSupportSystem.Api.Services.Projects;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/chat")]
[Authorize]
public sealed class ChatController(IChatService chatService, IProjectMembershipService projectMembershipService) : ControllerBase
{
    [HttpGet("projects")]
    public async Task<ActionResult<ServiceResponse<List<MyProjectSummaryResponse>>>> GetMyProjects()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<MyProjectSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await projectMembershipService.GetMyProjectsAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/messages")]
    public async Task<ActionResult<ServiceResponse<List<ChatMessageResponse>>>> GetMessages(
        [FromRoute] string projectId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<ChatMessageResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await chatService.GetMessagesAsync(userId, projectId, page, pageSize);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : result.Message == ErrorMessages.Forbidden
                ? Forbid()
                : BadRequest(result);
    }

    [HttpPost("projects/{projectId}/messages")]
    public async Task<ActionResult<ServiceResponse<ChatMessageResponse>>> SendTextMessage(
        [FromRoute] string projectId,
        [FromBody] SendChatMessageRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ChatMessageResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await chatService.SendTextMessageAsync(userId, projectId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("projects/{projectId}/messages/attachment")]
    [Consumes("multipart/form-data")]
    [RequestSizeLimit(10 * 1024 * 1024)]
    public async Task<ActionResult<ServiceResponse<ChatMessageResponse>>> SendAttachmentMessage(
        [FromRoute] string projectId,
        [FromForm] IFormFile file,
        [FromForm] string? caption,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ChatMessageResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        if (file is null)
        {
            return BadRequest(ServiceResponse<ChatMessageResponse>.Failure("Invalid file", ["file is required"]));
        }

        var result = await chatService.SendAttachmentMessageAsync(userId, projectId, file, caption, cancellationToken);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("messages/{messageId}/attachment")]
    public async Task<IActionResult> DownloadAttachment(
        [FromRoute] string messageId,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized();
        }

        var result = await chatService.OpenAttachmentAsync(userId, messageId, cancellationToken);
        if (!result.IsSuccess || result.Data is null)
        {
            return result.Message == ErrorMessages.Forbidden
                ? Forbid()
                : NotFound(result);
        }

        var (stream, contentType, fileName) = result.Data.Value;
        return File(stream, contentType, fileName);
    }

}
