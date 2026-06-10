using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class RegisterRequestValidator : AbstractValidator<RegisterRequest>
{
    public RegisterRequestValidator()
    {
        RuleFor(x => x.FullName)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(320);

        RuleFor(x => x.Password)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128);

        RuleFor(x => x.PhoneNumber)
            .MaximumLength(20);

        RuleFor(x => x.IdentifyNumber)
            .MaximumLength(20);

        RuleFor(x => x.Gender)
            .MaximumLength(20);

        RuleFor(x => x.Address)
            .MaximumLength(300);
    }
}
