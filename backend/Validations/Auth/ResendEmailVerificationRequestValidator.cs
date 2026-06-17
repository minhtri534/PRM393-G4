using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class ResendEmailVerificationRequestValidator : AbstractValidator<ResendEmailVerificationRequest>
{
    public ResendEmailVerificationRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(320);
    }
}
