using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using DataLabellingSupportSystem.Api.DTOs.Responses.Auth;
using DataLabellingSupportSystem.Api.Services.Auth;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/auth")]
public sealed class AuthController(IAuthService authService) : ControllerBase
{
    [HttpPost("register")]
    public async Task<ActionResult<ServiceResponse<RegisterResponse>>> Register([FromBody] RegisterRequest request)
    {
        var result = await authService.RegisterAsync(request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("verify-email-otp")]
    public async Task<ActionResult<ServiceResponse<AuthResponse>>> VerifyEmailOtp([FromBody] VerifyEmailOtpRequest request)
    {
        var result = await authService.VerifyEmailOtpAsync(request);
        return this.ToOkOrUnauthorized(result);
    }

    [HttpPost("resend-verification-otp")]
    public async Task<ActionResult<ServiceResponse<RegisterResponse>>> ResendVerificationOtp(
        [FromBody] ResendEmailVerificationRequest request)
    {
        var result = await authService.ResendEmailVerificationAsync(request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("login")]
    public async Task<ActionResult<ServiceResponse<AuthResponse>>> Login([FromBody] LoginRequest request)
    {
        var result = await authService.LoginAsync(request);
        return this.ToOkOrUnauthorized(result);
    }

    [HttpPost("login-google")]
    public async Task<ActionResult<ServiceResponse<AuthResponse>>> LoginGoogle([FromBody] GoogleLoginRequest request)
    {
        var result = await authService.LoginWithGoogleAsync(request);
        return this.ToOkOrUnauthorized(result);
    }

    [HttpPost("logout")]
    public async Task<ActionResult<ServiceResponse<bool>>> Logout([FromBody] LogoutRequest request)
    {
        var result = await authService.LogoutAsync(request);
        return Ok(result);
    }

    [HttpPost("refresh-token")]
    public async Task<ActionResult<ServiceResponse<AuthResponse>>> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        var result = await authService.RefreshTokenAsync(request);
        return this.ToOkOrUnauthorized(result);
    }

    [HttpPost("forgot-password")]
    public async Task<ActionResult<ServiceResponse<ForgotPasswordResponse>>> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        var result = await authService.ForgotPasswordAsync(request);
        return Ok(result);
    }

    [HttpPost("reset-password")]
    public async Task<ActionResult<ServiceResponse<bool>>> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        var result = await authService.ResetPasswordAsync(request);
        return this.ToOkOrUnauthorized(result);
    }

    [Authorize]
    [HttpPost("change-password")]
    public async Task<ActionResult<ServiceResponse<bool>>> ChangePassword([FromBody] ChangePasswordRequest request)
    {
        var userId = User.GetUserId();

        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await authService.ChangePasswordAsync(userId, request);
        return this.ToOkOrUnauthorized(result);
    }
}
