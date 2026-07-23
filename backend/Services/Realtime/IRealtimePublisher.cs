using DataLabellingSupportSystem.Api.DTOs.Responses.Notifications;

namespace DataLabellingSupportSystem.Api.Services.Realtime;

public interface IRealtimePublisher
{
    Task EmitNotificationsAsync(
        IReadOnlyList<(string RecipientUserId, NotificationResponse Notification)> items,
        CancellationToken cancellationToken = default);
}
