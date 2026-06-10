using DataLabellingSupportSystem.Api.DTOs.Requests.Roles;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Roles;

public sealed class CreateRoleRequestValidator : AbstractValidator<CreateRoleRequest>
{
    public CreateRoleRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
    }
}
