using DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Annotator;

public sealed class UpsertTaskItemAnnotationsRequestValidator : AbstractValidator<UpsertTaskItemAnnotationsRequest>
{
    public UpsertTaskItemAnnotationsRequestValidator()
    {
        RuleFor(x => x.Objects)
            .NotNull();

        RuleForEach(x => x.Objects)
            .SetValidator(new UpsertAnnotationObjectValidator());
    }

    private sealed class UpsertAnnotationObjectValidator : AbstractValidator<UpsertAnnotationObject>
    {
        public UpsertAnnotationObjectValidator()
        {
            RuleFor(x => x.LabelId)
                .NotEmpty()
                .Length(24);

            RuleFor(x => x.GeometryData.ValueKind)
                .NotEqual(System.Text.Json.JsonValueKind.Undefined)
                .WithMessage("GeometryData is required");
        }
    }
}
