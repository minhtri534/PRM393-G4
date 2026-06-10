using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Users;

public sealed class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
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

        RuleFor(x => x.RoleId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.Status)
            .InclusiveBetween(0, 1);

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
