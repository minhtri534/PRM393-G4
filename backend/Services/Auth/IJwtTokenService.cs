using DataLabellingSupportSystem.Api.Models;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public interface IJwtTokenService
{
    string CreateAccessToken(User user, string? roleName);
}
