using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Reviews;

public sealed class ApproveLabeledDataRequestValidator : AbstractValidator<ApproveLabeledDataRequest>
{
    public ApproveLabeledDataRequestValidator()
    {
        RuleFor(x => x.Score)
            .InclusiveBetween(0, 100);

        RuleFor(x => x.Comment)
            .MaximumLength(2000);
    }
}

public sealed class ReturnLabelWithFeedbackRequestValidator : AbstractValidator<ReturnLabelWithFeedbackRequest>
{
    public ReturnLabelWithFeedbackRequestValidator()
    {
        RuleFor(x => x.Feedback)
            .NotEmpty()
            .MaximumLength(4000);

        RuleFor(x => x.Score)
            .InclusiveBetween(0, 100);

        RuleForEach(x => x.ErrorTypeIds)
            .NotEmpty()
            .Length(24)
            .When(x => x.ErrorTypeIds is not null && x.ErrorTypeIds.Count > 0);
    }
}

public sealed class CreateReviewErrorRecordRequestValidator : AbstractValidator<CreateReviewErrorRecordRequest>
{
    public CreateReviewErrorRecordRequestValidator()
    {
        RuleFor(x => x.ErrorTypeId)
            .NotEmpty()
            .Length(24);
    }
}

public sealed class UpdateReviewErrorRecordRequestValidator : AbstractValidator<UpdateReviewErrorRecordRequest>
{
    public UpdateReviewErrorRecordRequestValidator()
    {
        RuleFor(x => x.OldErrorTypeId)
            .NotEmpty()
            .Length(24);

        RuleFor(x => x.NewErrorTypeId)
            .NotEmpty()
            .Length(24);
    }
}