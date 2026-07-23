using System.Net.Http.Json;
using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.DTOs.Responses.Notifications;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Realtime;

public sealed class RealtimePublisher(
    IHttpClientFactory httpClientFactory,
    IOptions<RealtimeOptions> options,
    ILogger<RealtimePublisher> logger) : IRealtimePublisher
{
    public async Task EmitNotificationsAsync(
        IReadOnlyList<(string RecipientUserId, NotificationResponse Notification)> items,
        CancellationToken cancellationToken = default)
    {
        if (items.Count == 0)
        {
            return;
        }

        var opt = options.Value;
        var baseUrl = (opt.BaseUrl ?? string.Empty).TrimEnd('/');
        if (string.IsNullOrWhiteSpace(baseUrl))
        {
            return;
        }

        try
        {
            var client = httpClientFactory.CreateClient("Realtime");
            var payload = new
            {
                eventName = "notification:new",
                deliveries = items.Select(x => new
                {
                    userId = x.RecipientUserId,
                    data = x.Notification
                }).ToList()
            };

            using var request = new HttpRequestMessage(HttpMethod.Post, $"{baseUrl}/internal/emit")
            {
                Content = JsonContent.Create(payload)
            };
            request.Headers.TryAddWithoutValidation("X-Internal-Key", opt.InternalKey);

            var response = await client.SendAsync(request, cancellationToken);
            if (!response.IsSuccessStatusCode)
            {
                var body = await response.Content.ReadAsStringAsync(cancellationToken);
                logger.LogWarning(
                    "Realtime emit failed status={Status} body={Body}",
                    (int)response.StatusCode,
                    body);
            }
        }
        catch (Exception ex)
        {
            // Persistence already succeeded — do not fail the business action if sockets are down.
            logger.LogWarning(ex, "Failed to emit realtime notifications");
        }
    }
}
