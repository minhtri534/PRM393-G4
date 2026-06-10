using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Users;

public sealed class UpdateUserRequestValidator : AbstractValidator<UpdateUserRequest>
{
    public UpdateUserRequestValidator()
    {
        RuleFor(x => x.FullName)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(320);

        RuleFor(x => x.Password)
            .MinimumLength(8)
            .MaximumLength(128)
            .When(x => !string.IsNullOrWhiteSpace(x.Password));

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
