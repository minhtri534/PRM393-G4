namespace DataLabellingSupportSystem.Api.Configurations;

public sealed class RealtimeOptions
{
    public string BaseUrl { get; init; } = "http://localhost:5001";

    public string InternalKey { get; init; } = "DLSS_DEV_REALTIME_INTERNAL_KEY";
}
