using System.Net;
using System.Net.Mail;
using DataLabellingSupportSystem.Api.Configurations;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Email;

public sealed class SmtpEmailSender(
    IOptions<EmailOptions> options,
    ILogger<SmtpEmailSender> logger) : IEmailSender
{
    public async Task SendAsync(
        string toEmail,
        string subject,
        string body,
        CancellationToken cancellationToken = default)
    {
        var emailOptions = options.Value;
        if (string.IsNullOrWhiteSpace(emailOptions.SmtpHost))
        {
            throw new InvalidOperationException("SMTP host is not configured.");
        }

        using var message = new MailMessage
        {
            From = new MailAddress(emailOptions.FromAddress, emailOptions.FromName),
            Subject = subject,
            Body = body,
            IsBodyHtml = false,
        };
        message.To.Add(toEmail);

        using var client = new SmtpClient(emailOptions.SmtpHost, emailOptions.SmtpPort)
        {
            EnableSsl = emailOptions.SmtpUseSsl,
            Credentials = string.IsNullOrWhiteSpace(emailOptions.SmtpUsername)
                ? null
                : new NetworkCredential(emailOptions.SmtpUsername, emailOptions.SmtpPassword),
        };

        await client.SendMailAsync(message, cancellationToken);
        logger.LogInformation("Email sent to {ToEmail} with subject {Subject}", toEmail, subject);
    }
}
