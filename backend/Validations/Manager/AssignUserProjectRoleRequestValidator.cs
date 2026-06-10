using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class AssignUserProjectRoleRequestValidator : AbstractValidator<AssignUserProjectRoleRequest>
{
    public AssignUserProjectRoleRequestValidator()
    {
        RuleFor(x => x.UserId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.ProjectId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.RoleId)
            .NotEmpty()
            .Length(24);
    }
}
