using DataLabellingSupportSystem.Api.Common.Results;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

public static class ControllerBaseExtensions
{
    public static ActionResult<ServiceResponse<T>> ToOkOrBadRequest<T>(this ControllerBase controller, ServiceResponse<T> result)
        => result.IsSuccess ? controller.Ok(result) : controller.BadRequest(result);

    public static ActionResult<ServiceResponse<T>> ToOkOrUnauthorized<T>(this ControllerBase controller, ServiceResponse<T> result)
        => result.IsSuccess ? controller.Ok(result) : controller.Unauthorized(result);

    public static ActionResult<ServiceResponse<T>> ToOkOrStatusCode<T>(this ControllerBase controller, ServiceResponse<T> result, int failureStatusCode)
        => result.IsSuccess ? controller.Ok(result) : controller.StatusCode(failureStatusCode, result);
}
