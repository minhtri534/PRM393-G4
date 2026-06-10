using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class GoogleLoginRequestValidator : AbstractValidator<GoogleLoginRequest>
{
    public GoogleLoginRequestValidator()
    {
        RuleFor(x => x.IdToken)
            .NotEmpty();
    }
}
