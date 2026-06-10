using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using DataLabellingSupportSystem.Api.DTOs.Responses.Auth;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public sealed class AuthService(
    AppDbContext dbContext,
    IOptions<JwtOptions> jwtOptions,
    IJwtTokenService jwtTokenService,
    IGoogleIdTokenValidator googleIdTokenValidator,
    ISecureTokenGenerator secureTokenGenerator,
    IPasswordHasher passwordHasher) : IAuthService
{
    private readonly JwtOptions _jwt = jwtOptions.Value;

    private const string DefaultAnnotatorRoleId = "000000000000000000000003";

    public async Task<ServiceResponse<AuthResponse>> RegisterAsync(RegisterRequest request)
    {
        var normalizedEmail = NormalizeEmail(request.Email);

        if (await EmailExistsAsync(normalizedEmail))
        {
            return ServiceResponse<AuthResponse>.Failure("Email already exists", ["Email is already registered"]);
        }

        var ensureRole = await EnsureDefaultRoleExistsAsync();
        if (!ensureRole.IsSuccess)
        {
            return ServiceResponse<AuthResponse>.Failure(ensureRole.Message, ensureRole.Errors);
        }

        var user = CreateUserFromRegisterRequest(request, normalizedEmail);
        dbContext.Users.Add(user);
        await dbContext.SaveChangesAsync();

        return await IssueTokensForUserAsync(user.Id);
    }

    public async Task<ServiceResponse<AuthResponse>> LoginAsync(LoginRequest request)
    {
        var normalizedEmail = NormalizeEmail(request.Email);
        var user = await FindUserByEmailAsync(normalizedEmail, asNoTracking: true);
        if (user is null)
        {
            return ServiceResponse<AuthResponse>.Failure(ErrorMessages.Unauthorized, ["Invalid credentials"]);
        }

        var activeCheck = EnsureUserIsActive(user);
        if (!activeCheck.IsSuccess)
        {
            return ServiceResponse<AuthResponse>.Failure(activeCheck.Message, activeCheck.Errors);
        }

        if (!passwordHasher.Verify(request.Password, user.PasswordHash))
        {
            return ServiceResponse<AuthResponse>.Failure(ErrorMessages.Unauthorized, ["Invalid credentials"]);
        }

        return await IssueTokensForUserAsync(user.Id);
    }

    public async Task<ServiceResponse<AuthResponse>> LoginWithGoogleAsync(GoogleLoginRequest request)
    {
        var payloadResult = await googleIdTokenValidator.ValidateAsync(request.IdToken);
        if (!payloadResult.IsSuccess || payloadResult.Data is null)
        {
            return ServiceResponse<AuthResponse>.Failure(payloadResult.Message, payloadResult.Errors);
        }

        var email = NormalizeEmail(payloadResult.Data.Email ?? string.Empty);
        if (string.IsNullOrWhiteSpace(email))
        {
            return ServiceResponse<AuthResponse>.Failure(ErrorMessages.Unauthorized, ["Google account has no email"]);
        }

        var user = await FindUserByEmailAsync(email, asNoTracking: false);
        if (user is null)
        {
            var ensureRole = await EnsureDefaultRoleExistsAsync();
            if (!ensureRole.IsSuccess)
            {
                return ServiceResponse<AuthResponse>.Failure(ensureRole.Message, ensureRole.Errors);
            }

            user = CreateUserFromGooglePayload(payloadResult.Data, email);
            dbContext.Users.Add(user);
            await dbContext.SaveChangesAsync();
        }

        var activeCheck = EnsureUserIsActive(user);
        if (!activeCheck.IsSuccess)
        {
            return ServiceResponse<AuthResponse>.Failure(activeCheck.Message, activeCheck.Errors);
        }

        return await IssueTokensForUserAsync(user.Id);
    }

    public async Task<ServiceResponse<bool>> LogoutAsync(LogoutRequest request)
    {
        await RevokeRefreshTokenIfExistsAsync(request.RefreshToken);
        return ServiceResponse<bool>.Success(true, "Logged out");
    }

    public async Task<ServiceResponse<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request)
    {
        var now = DlssTime.VietnamNow;
        var token = request.RefreshToken.Trim();
        var existing = await dbContext.RefreshTokens.FirstOrDefaultAsync(x => x.Token == token);
        if (existing is null || existing.IsRevoked || existing.ExpiresAt <= now)
        {
            return ServiceResponse<AuthResponse>.Failure(ErrorMessages.Unauthorized, ["Invalid refresh token"]);
        }

        existing.RevokedAt = now;
        await dbContext.SaveChangesAsync();

        return await IssueTokensForUserAsync(existing.UserId);
    }

    public async Task<ServiceResponse<ForgotPasswordResponse>> ForgotPasswordAsync(ForgotPasswordRequest request)
    {
        var now = DlssTime.VietnamNow;
        var normalizedEmail = NormalizeEmail(request.Email);
        var user = await FindUserByEmailAsync(normalizedEmail, asNoTracking: true);
        if (user is null)
        {
            return ServiceResponse<ForgotPasswordResponse>.Success(new ForgotPasswordResponse(null), "If the email exists, a reset token has been generated");
        }

        var resetToken = secureTokenGenerator.Generate();
        dbContext.PasswordResetTokens.Add(new PasswordResetToken
        {
            Token = resetToken,
            UserId = user.Id,
            ExpiresAt = now.AddHours(1)
        });

        await dbContext.SaveChangesAsync();
        return ServiceResponse<ForgotPasswordResponse>.Success(new ForgotPasswordResponse(resetToken), "Reset token generated (dev mode)");
    }

    public async Task<ServiceResponse<bool>> ResetPasswordAsync(ResetPasswordRequest request)
    {
        var now = DlssTime.VietnamNow;
        var normalizedEmail = NormalizeEmail(request.Email);
        var user = await FindUserByEmailAsync(normalizedEmail, asNoTracking: false);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Invalid token"]);
        }

        var token = request.ResetToken.Trim();
        var reset = await dbContext.PasswordResetTokens
            .FirstOrDefaultAsync(x => x.UserId == user.Id && x.Token == token);

        if (reset is null || reset.IsUsed || reset.ExpiresAt <= now)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Invalid token"]);
        }

        user.PasswordHash = passwordHasher.Hash(request.NewPassword);
        reset.UsedAt = now;

        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Password reset successfully");
    }

    public async Task<ServiceResponse<bool>> ChangePasswordAsync(string userId, ChangePasswordRequest request)
    {
        var user = await dbContext.Users.FirstOrDefaultAsync(x => x.Id == userId);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        if (!passwordHasher.Verify(request.CurrentPassword, user.PasswordHash))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Invalid current password"]);
        }

        user.PasswordHash = passwordHasher.Hash(request.NewPassword);
        await dbContext.SaveChangesAsync();
        return ServiceResponse<bool>.Success(true, "Password changed successfully");
    }

    private async Task<ServiceResponse<AuthResponse>> IssueTokensForUserAsync(string userId)
    {
        var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId);
        if (user is null)
        {
            return ServiceResponse<AuthResponse>.Failure(ErrorMessages.Unauthorized, ["User not found"]);
        }

        var roleName = await GetRoleNameAsync(user.RoleId);
        var accessToken = jwtTokenService.CreateAccessToken(user, roleName);
        var refreshToken = secureTokenGenerator.Generate();

        await StoreRefreshTokenAsync(user.Id, refreshToken);

        return ServiceResponse<AuthResponse>.Success(
            BuildAuthResponse(user, roleName, accessToken, refreshToken),
            "Authenticated");
    }

    private static string NormalizeEmail(string email) => email.Trim().ToLowerInvariant();

    private Task<bool> EmailExistsAsync(string normalizedEmail)
        => dbContext.Users.AsNoTracking().AnyAsync(x => x.Email == normalizedEmail);

    private async Task<ServiceResponse<bool>> EnsureDefaultRoleExistsAsync()
    {
        var roleExists = await dbContext.Roles.AsNoTracking().AnyAsync(x => x.Id == DefaultAnnotatorRoleId);
        return roleExists
            ? ServiceResponse<bool>.Success(true)
            : ServiceResponse<bool>.Failure("Default role missing", ["Annotator role not found"]);
    }

    private Task<User?> FindUserByEmailAsync(string normalizedEmail, bool asNoTracking)
    {
        var query = asNoTracking ? dbContext.Users.AsNoTracking() : dbContext.Users;
        return query.FirstOrDefaultAsync(x => x.Email == normalizedEmail);
    }

    private static ServiceResponse<bool> EnsureUserIsActive(User user)
    {
        return user.Status == 0
            ? ServiceResponse<bool>.Success(true)
            : ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["User is not active"]);
    }

    private User CreateUserFromRegisterRequest(RegisterRequest request, string normalizedEmail)
    {
        return new User
        {
            FullName = request.FullName.Trim(),
            Email = normalizedEmail,
            PhoneNumber = request.PhoneNumber,
            IdentifyNumber = request.IdentifyNumber,
            Gender = request.Gender,
            Address = request.Address,
            DateOfBirth = request.DateOfBirth,
            PasswordHash = passwordHasher.Hash(request.Password),
            RoleId = DefaultAnnotatorRoleId,
            Status = 0
        };
    }

    private User CreateUserFromGooglePayload(Google.Apis.Auth.GoogleJsonWebSignature.Payload payload, string normalizedEmail)
    {
        return new User
        {
            FullName = payload.Name ?? payload.Email ?? string.Empty,
            Email = normalizedEmail,
            PasswordHash = passwordHasher.Hash(secureTokenGenerator.Generate()),
            RoleId = DefaultAnnotatorRoleId,
            Status = 0
        };
    }

    private async Task RevokeRefreshTokenIfExistsAsync(string refreshToken)
    {
        var now = DlssTime.VietnamNow;
        var token = refreshToken.Trim();
        if (string.IsNullOrWhiteSpace(token))
        {
            return;
        }

        var existing = await dbContext.RefreshTokens.FirstOrDefaultAsync(x => x.Token == token);
        if (existing is null || existing.IsRevoked)
        {
            return;
        }

        existing.RevokedAt = now;
        await dbContext.SaveChangesAsync();
    }

    private Task<string?> GetRoleNameAsync(string roleId)
        => dbContext.Roles.AsNoTracking()
            .Where(x => x.Id == roleId)
            .Select(x => x.Name)
            .FirstOrDefaultAsync();

    private async Task StoreRefreshTokenAsync(string userId, string refreshToken)
    {
        var now = DlssTime.VietnamNow;
        dbContext.RefreshTokens.Add(new RefreshToken
        {
            Token = refreshToken,
            UserId = userId,
            ExpiresAt = now.AddDays(_jwt.RefreshTokenDays)
        });

        await dbContext.SaveChangesAsync();
    }

    private static AuthResponse BuildAuthResponse(User user, string? roleName, string accessToken, string refreshToken)
    {
        return new AuthResponse(
            accessToken,
            refreshToken,
            new UserProfileResponse(
                user.Id,
                user.FullName,
                user.Email,
                user.RoleId,
                roleName,
                user.Status));
    }

}
