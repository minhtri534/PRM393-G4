using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Users;

public sealed class UpdateOwnProfileRequestValidator : AbstractValidator<UpdateOwnProfileRequest>
{
    public UpdateOwnProfileRequestValidator()
    {
        RuleFor(x => x.FullName)
            .NotEmpty()
            .MaximumLength(150);

        RuleFor(x => x.Email)
            .NotEmpty()
            .EmailAddress()
            .MaximumLength(320);

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
