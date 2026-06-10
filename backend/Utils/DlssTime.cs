namespace DataLabellingSupportSystem.Api.Utils;

public static class DlssTime
{
    private static readonly TimeZoneInfo VietnamTimeZone = ResolveVietnamTimeZone();

    public static DateTime VietnamNow => TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, VietnamTimeZone);

    private static TimeZoneInfo ResolveVietnamTimeZone()
    {
        // Windows
        try
        {
            return TimeZoneInfo.FindSystemTimeZoneById("SE Asia Standard Time");
        }
        catch
        {
            // Linux/macOS or fallback
            try
            {
                return TimeZoneInfo.FindSystemTimeZoneById("Asia/Ho_Chi_Minh");
            }
            catch
            {
                return TimeZoneInfo.CreateCustomTimeZone(
                    id: "Asia/Ho_Chi_Minh",
                    baseUtcOffset: TimeSpan.FromHours(7),
                    displayName: "Vietnam Time (UTC+07:00)",
                    standardDisplayName: "Vietnam Time");
            }
        }
    }
}
