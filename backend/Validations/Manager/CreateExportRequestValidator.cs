using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class CreateExportRequestValidator : AbstractValidator<CreateExportRequest>
{
    public CreateExportRequestValidator()
    {
        RuleFor(x => x.ProjectId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.Format)
            .NotEmpty()
            .MaximumLength(50);

        RuleFor(x => x.ExportPath)
            .NotEmpty()
            .MaximumLength(500);

        RuleFor(x => x.LabelFormat)
            .NotEmpty()
            .MaximumLength(100);

        RuleForEach(x => x.IncludeFields)
            .MaximumLength(100);

        RuleForEach(x => x.Filters!.Keys)
            .MaximumLength(100)
            .When(x => x.Filters is not null && x.Filters.Count > 0);

        RuleForEach(x => x.Filters!.Values)
            .MaximumLength(500)
            .When(x => x.Filters is not null && x.Filters.Count > 0);
    }
}
