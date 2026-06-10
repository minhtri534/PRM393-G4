using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class ResetPasswordRequestValidator : AbstractValidator<ResetPasswordRequest>
{
    public ResetPasswordRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress();

        RuleFor(x => x.ResetToken)
            .NotEmpty();

        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128);
    }
}
