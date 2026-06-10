using System.Text.Json;
using DataLabellingSupportSystem.Api.Common.Results;

namespace DataLabellingSupportSystem.Api.Middlewares;

public sealed class GlobalExceptionHandler(RequestDelegate next, ILogger<GlobalExceptionHandler> logger)
{
    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception");

            if (context.Response.HasStarted)
            {
                throw;
            }

            context.Response.Clear();
            context.Response.StatusCode = StatusCodes.Status500InternalServerError;
            context.Response.ContentType = "application/json";

            var response = ServiceResponse<object>.Failure(
                "Internal server error",
                ["An unexpected error occurred"]);

            await context.Response.WriteAsync(JsonSerializer.Serialize(response));
        }
    }
}
