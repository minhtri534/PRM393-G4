namespace DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;

public sealed record SendProjectNotificationRequest(
    string Title,
    string? Body);
