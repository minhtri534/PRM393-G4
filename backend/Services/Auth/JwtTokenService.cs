using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public sealed class JwtTokenService(IOptions<JwtOptions> jwtOptions) : IJwtTokenService
{
    private readonly JwtOptions _jwt = jwtOptions.Value;

    public string CreateAccessToken(User user, string? roleName)
    {
        if (string.IsNullOrWhiteSpace(_jwt.SigningKey) || _jwt.SigningKey.Length < 32)
        {
            throw new InvalidOperationException("Jwt:SigningKey must be at least 32 characters");
        }

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_jwt.SigningKey));
        var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, user.Id),
            new(JwtRegisteredClaimNames.Email, user.Email),
            new("roleId", user.RoleId)
        };

        if (!string.IsNullOrWhiteSpace(roleName))
        {
            claims.Add(new Claim("role", roleName));
            claims.Add(new Claim(ClaimTypes.Role, roleName));
            claims.Add(new Claim("roleName", roleName));
        }

        var token = new JwtSecurityToken(
            issuer: _jwt.Issuer,
            audience: _jwt.Audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(_jwt.AccessTokenMinutes),
            signingCredentials: creds);

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
