using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using DataLabellingSupportSystem.Api.DTOs.Responses.Auth;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public interface IAuthService
{
    Task<ServiceResponse<RegisterResponse>> RegisterAsync(RegisterRequest request);
    Task<ServiceResponse<AuthResponse>> VerifyEmailOtpAsync(VerifyEmailOtpRequest request);
    Task<ServiceResponse<RegisterResponse>> ResendEmailVerificationAsync(ResendEmailVerificationRequest request);
    Task<ServiceResponse<AuthResponse>> LoginAsync(LoginRequest request);
    Task<ServiceResponse<AuthResponse>> LoginWithGoogleAsync(GoogleLoginRequest request);
    Task<ServiceResponse<bool>> LogoutAsync(LogoutRequest request);
    Task<ServiceResponse<AuthResponse>> RefreshTokenAsync(RefreshTokenRequest request);
    Task<ServiceResponse<ForgotPasswordResponse>> ForgotPasswordAsync(ForgotPasswordRequest request);
    Task<ServiceResponse<bool>> ResetPasswordAsync(ResetPasswordRequest request);
    Task<ServiceResponse<bool>> ChangePasswordAsync(string userId, ChangePasswordRequest request);
}
