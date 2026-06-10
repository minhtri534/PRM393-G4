using DataLabellingSupportSystem.Api.Common.Results;
using Google.Apis.Auth;

namespace DataLabellingSupportSystem.Api.Services.Auth;

public interface IGoogleIdTokenValidator
{
    Task<ServiceResponse<GoogleJsonWebSignature.Payload>> ValidateAsync(string idToken);
}
