namespace DataLabellingSupportSystem.Api.Configurations;

public sealed class EmailOptions
{
    public string Provider { get; init; } = "Console";

    public string FromAddress { get; init; } = "noreply@dlss.local";

    public string FromName { get; init; } = "DLSS";

    public string? SmtpHost { get; init; }

    public int SmtpPort { get; init; } = 587;

    public string? SmtpUsername { get; init; }

    public string? SmtpPassword { get; init; }

    public bool SmtpUseSsl { get; init; } = true;
}
