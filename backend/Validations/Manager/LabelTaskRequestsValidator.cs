using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Manager;

public sealed class CreateLabelRequestValidator : AbstractValidator<CreateLabelRequest>
{
    public CreateLabelRequestValidator()
    {
        RuleFor(x => x.ProjectId).NotEmpty().Length(24);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.YoloClassId).GreaterThanOrEqualTo(0);
        RuleFor(x => x.CategoryId).Length(24).When(x => !string.IsNullOrWhiteSpace(x.CategoryId));
        RuleFor(x => x.AnnotationTypeId).Length(24).When(x => !string.IsNullOrWhiteSpace(x.AnnotationTypeId));
    }
}

public sealed class UpdateLabelRequestValidator : AbstractValidator<UpdateLabelRequest>
{
    public UpdateLabelRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.YoloClassId).GreaterThanOrEqualTo(0);
        RuleFor(x => x.CategoryId).Length(24).When(x => !string.IsNullOrWhiteSpace(x.CategoryId));
        RuleFor(x => x.AnnotationTypeId).Length(24).When(x => !string.IsNullOrWhiteSpace(x.AnnotationTypeId));
    }
}

public sealed class CreateLabelCategoryRequestValidator : AbstractValidator<CreateLabelCategoryRequest>
{
    public CreateLabelCategoryRequestValidator()
    {
        RuleFor(x => x.ProjectId).NotEmpty().Length(24);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(500);
    }
}

public sealed class UpdateLabelCategoryRequestValidator : AbstractValidator<UpdateLabelCategoryRequest>
{
    public UpdateLabelCategoryRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Description).MaximumLength(500);
    }
}

public sealed class CreateAnnotationTypeRequestValidator : AbstractValidator<CreateAnnotationTypeRequest>
{
    public CreateAnnotationTypeRequestValidator()
    {
        RuleFor(x => x.ProjectId).NotEmpty().Length(24);
        RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
        RuleFor(x => x.Description).MaximumLength(500);
    }
}

public sealed class UpdateAnnotationTypeRequestValidator : AbstractValidator<UpdateAnnotationTypeRequest>
{
    public UpdateAnnotationTypeRequestValidator()
    {
        RuleFor(x => x.Name).NotEmpty().MaximumLength(50);
        RuleFor(x => x.Description).MaximumLength(500);
    }
}

public sealed class CreateTaskRequestValidator : AbstractValidator<CreateTaskRequest>
{
    public CreateTaskRequestValidator()
    {
        RuleFor(x => x.ProjectId).NotEmpty().Length(24);
        RuleFor(x => x.DataItemId).NotEmpty().Length(24);
        RuleFor(x => x.AnnotatorId).NotEmpty().Length(24);
    }
}

public sealed class AssignTaskRequestValidator : AbstractValidator<AssignTaskRequest>
{
    public AssignTaskRequestValidator()
    {
        RuleFor(x => x.AnnotatorId).NotEmpty().Length(24);
    }
}

public sealed class BulkAssignTasksRequestValidator : AbstractValidator<BulkAssignTasksRequest>
{
    public BulkAssignTasksRequestValidator()
    {
        RuleFor(x => x.AnnotatorId).NotEmpty().Length(24);
        RuleFor(x => x.TaskIds).NotEmpty();
        RuleForEach(x => x.TaskIds).NotEmpty().Length(24);
    }
}

public sealed class UpdateProjectGuidelineRequestValidator : AbstractValidator<UpdateProjectGuidelineRequest>
{
    public UpdateProjectGuidelineRequestValidator()
    {
        RuleFor(x => x.Guideline).MaximumLength(10000);
    }
}

public sealed class RequestRelabelingRequestValidator : AbstractValidator<RequestRelabelingRequest>
{
    public RequestRelabelingRequestValidator()
    {
        RuleFor(x => x.Reason).NotEmpty().MaximumLength(1000);
    }
}
