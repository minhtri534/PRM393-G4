using DataLabellingSupportSystem.Api.DTOs.Requests.Admin;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Admin;

public sealed class ResetUserPasswordRequestValidator : AbstractValidator<ResetUserPasswordRequest>
{
    public ResetUserPasswordRequestValidator()
    {
        RuleFor(x => x.NewPassword)
            .NotEmpty()
            .MinimumLength(8)
            .MaximumLength(128);
    }
}

public sealed class AssignRolePermissionRequestValidator : AbstractValidator<AssignRolePermissionRequest>
{
    public AssignRolePermissionRequestValidator()
    {
        RuleFor(x => x.RoleId)
            .NotEmpty()
            .Length(24);
    }
}

public sealed class UpdateSystemSettingsRequestValidator : AbstractValidator<UpdateSystemSettingsRequest>
{
    public UpdateSystemSettingsRequestValidator()
    {
        RuleFor(x => x.StorageLocalRootPath)
            .MaximumLength(260)
            .When(x => !string.IsNullOrWhiteSpace(x.StorageLocalRootPath));
    }
}