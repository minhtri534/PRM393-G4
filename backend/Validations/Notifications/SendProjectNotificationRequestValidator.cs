using FluentValidation;
using DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;

namespace DataLabellingSupportSystem.Api.Validations.Notifications;

public sealed class SendProjectNotificationRequestValidator : AbstractValidator<SendProjectNotificationRequest>
{
    public SendProjectNotificationRequestValidator()
    {
        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(200);

        RuleFor(x => x.Body)
            .MaximumLength(1000)
            .When(x => x.Body is not null);
    }
}
