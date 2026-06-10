using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Configurations;
using Google.Apis.Auth;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public sealed class GoogleIdTokenValidator(
    IOptions<GoogleAuthOptions> googleOptions,
    ILogger<GoogleIdTokenValidator> logger) : IGoogleIdTokenValidator
{
    private readonly GoogleAuthOptions _google = googleOptions.Value;

    public async Task<ServiceResponse<GoogleJsonWebSignature.Payload>> ValidateAsync(string idToken)
    {
        if (string.IsNullOrWhiteSpace(_google.ClientId))
        {
            return ServiceResponse<GoogleJsonWebSignature.Payload>.Failure(
                "Google auth not configured",
                ["GoogleAuth:ClientId is empty"]);
        }

        try
        {
            var payload = await GoogleJsonWebSignature.ValidateAsync(idToken, new GoogleJsonWebSignature.ValidationSettings
            {
                Audience = [_google.ClientId]
            });

            return ServiceResponse<GoogleJsonWebSignature.Payload>.Success(payload);
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "Invalid Google id token");
            return ServiceResponse<GoogleJsonWebSignature.Payload>.Failure(ErrorMessages.Unauthorized, ["Invalid Google token"]);
        }
    }
}
