namespace DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;

public sealed record MarkNotificationsReadRequest(
    List<string>? Ids);
