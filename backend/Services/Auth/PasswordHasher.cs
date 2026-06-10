namespace DataLabellingSupportSystem.Api.Services.Auth;

using BCryptNet = BCrypt.Net.BCrypt;

public sealed class PasswordHasher : IPasswordHasher
{
    public string Hash(string password) => BCryptNet.HashPassword(password, workFactor: 10);

    public bool Verify(string password, string passwordHash) => BCryptNet.Verify(password, passwordHash);
}
