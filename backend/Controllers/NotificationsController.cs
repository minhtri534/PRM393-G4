using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;
using DataLabellingSupportSystem.Api.DTOs.Responses.Notifications;
using DataLabellingSupportSystem.Api.Services.Notifications;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize]
public sealed class NotificationsController(INotificationService notificationService) : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult<ServiceResponse<List<NotificationResponse>>>> GetMyNotifications(
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 30,
        [FromQuery] bool unreadOnly = false)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<NotificationResponse>>.Failure(
                ErrorMessages.Unauthorized,
                ["Missing user id claim"]));
        }

        var result = await notificationService.GetMyNotificationsAsync(userId, page, pageSize, unreadOnly);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("unread-count")]
    public async Task<ActionResult<ServiceResponse<int>>> GetUnreadCount()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(
                ErrorMessages.Unauthorized,
                ["Missing user id claim"]));
        }

        var result = await notificationService.GetUnreadCountAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("mark-read")]
    public async Task<ActionResult<ServiceResponse<int>>> MarkRead([FromBody] MarkNotificationsReadRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(
                ErrorMessages.Unauthorized,
                ["Missing user id claim"]));
        }

        var result = await notificationService.MarkReadAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("mark-all-read")]
    public async Task<ActionResult<ServiceResponse<int>>> MarkAllRead()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(
                ErrorMessages.Unauthorized,
                ["Missing user id claim"]));
        }

        var result = await notificationService.MarkAllReadAsync(userId);
        return this.ToOkOrBadRequest(result);
    }
}
