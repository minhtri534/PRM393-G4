using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class UpdateProjectRequestValidator : AbstractValidator<UpdateProjectRequest>
{
    public UpdateProjectRequestValidator()
    {
        RuleFor(x => x.Name)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Guideline)
            .MaximumLength(10000);

        RuleFor(x => x.Status)
            .InclusiveBetween(0, 10);
    }
}
