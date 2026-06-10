using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class ForgotPasswordRequestValidator : AbstractValidator<ForgotPasswordRequest>
{
    public ForgotPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress();
    }
}
