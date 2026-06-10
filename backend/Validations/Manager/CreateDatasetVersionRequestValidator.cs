using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class CreateDatasetVersionRequestValidator : AbstractValidator<CreateDatasetVersionRequest>
{
    public CreateDatasetVersionRequestValidator()
    {
        RuleFor(x => x.DatasetId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.VersionName)
            .NotEmpty()
            .MaximumLength(150);
    }
}
