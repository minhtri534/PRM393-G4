using DataLabellingSupportSystem.Api.DTOs.Requests.Roles;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Roles;

public sealed class UpdateRoleRequestValidator : AbstractValidator<UpdateRoleRequest>
{
    public UpdateRoleRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(100);
    }
}
