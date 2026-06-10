using System.Security.Cryptography;
using System.Text;

namespace DataLabellingSupportSystem.Api.Utils;

public static class ObjectId
{
    private static int _counter = RandomNumberGenerator.GetInt32(0, 0xFFFFFF);

    public static string NewObjectId()
    {
        Span<byte> bytes = stackalloc byte[12];

        var timestamp = (int)DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        bytes[0] = (byte)(timestamp >> 24);
        bytes[1] = (byte)(timestamp >> 16);
        bytes[2] = (byte)(timestamp >> 8);
        bytes[3] = (byte)timestamp;

        Span<byte> random = stackalloc byte[5];
        RandomNumberGenerator.Fill(random);
        random.CopyTo(bytes.Slice(4, 5));

        var counter = Interlocked.Increment(ref _counter) & 0xFFFFFF;
        bytes[9] = (byte)(counter >> 16);
        bytes[10] = (byte)(counter >> 8);
        bytes[11] = (byte)counter;

        return ToHexString(bytes);
    }

    private static string ToHexString(ReadOnlySpan<byte> bytes)
    {
        var builder = new StringBuilder(bytes.Length * 2);
        foreach (var b in bytes)
        {
            builder.Append(b.ToString("x2"));
        }

        return builder.ToString();
    }
}
