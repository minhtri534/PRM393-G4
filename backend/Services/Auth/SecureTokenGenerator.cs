using System.Security.Cryptography;
using Microsoft.AspNetCore.WebUtilities;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public sealed class SecureTokenGenerator : ISecureTokenGenerator
{
    public string Generate()
    {
        Span<byte> bytes = stackalloc byte[64];
        RandomNumberGenerator.Fill(bytes);
        return WebEncoders.Base64UrlEncode(bytes);
    }
}
