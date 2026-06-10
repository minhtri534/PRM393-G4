using DataLabellingSupportSystem.Api.DTOs.Requests.Auth;
using FluentValidation;

namespace DataLabellingSupportSystem.Api.Validations.Auth;

public sealed class LogoutRequestValidator : AbstractValidator<LogoutRequest>
{
    public LogoutRequestValidator()
    {
        RuleFor(x => x.RefreshToken)
            .NotEmpty();
    }
}
