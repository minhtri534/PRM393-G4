namespace DataLabellingSupportSystem.Api.Configurations;

public sealed record JwtOptions
{
    public string Issuer { get; init; } = "";
    public string Audience { get; init; } = "";
    public string SigningKey { get; init; } = "";
    public int AccessTokenMinutes { get; init; } = 30;
    public int RefreshTokenDays { get; init; } = 7;
}
