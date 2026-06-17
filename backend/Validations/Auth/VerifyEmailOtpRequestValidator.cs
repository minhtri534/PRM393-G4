using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class VerifyEmailOtpRequestValidator : AbstractValidator<VerifyEmailOtpRequest>
{
    public VerifyEmailOtpRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(320);

        RuleFor(x => x.OtpCode)
            .NotEmpty()
            .Matches(@"^\d{6}$")
            .WithMessage("Verification code must be a 6-digit number");
    }
}
