using DataLabellingSupportSystem.Api.Configurations;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Email;

public sealed class ConsoleEmailSender(
    IOptions<EmailOptions> options,
    ILogger<ConsoleEmailSender> logger) : IEmailSender
{
    public Task SendAsync(
        string toEmail,
        string subject,
        string body,
        CancellationToken cancellationToken = default)
    {
        var from = options.Value.FromAddress;
        logger.LogInformation(
            "DEV EMAIL -> To: {ToEmail} | From: {FromAddress} | Subject: {Subject}\n{Body}",
            toEmail,
            from,
            subject,
            body);
        return Task.CompletedTask;
    }
}
