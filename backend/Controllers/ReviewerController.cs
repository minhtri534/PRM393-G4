using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using DataLabellingSupportSystem.Api.DTOs.Responses.Reviews;
using DataLabellingSupportSystem.Api.Services.Reviews;
using DataLabellingSupportSystem.Api.Services.Storage;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/reviewer")]
[Authorize(Roles = "Reviewer")]
public sealed class ReviewerController(IReviewerWorkflowService reviewerWorkflowService) : ControllerBase
{
    [HttpGet("projects")]
    public async Task<ActionResult<ServiceResponse<List<MyProjectSummaryResponse>>>> GetMyProjects()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<MyProjectSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.GetMyProjectsAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("tasks/submitted")]
    public async Task<ActionResult<ServiceResponse<List<ReviewerSubmittedTaskResponse>>>> ViewSubmittedTasks([FromQuery] string? projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<ReviewerSubmittedTaskResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.GetSubmittedTasksAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("tasks/{taskId}/labeled-data")]
    public async Task<ActionResult<ServiceResponse<ReviewerLabeledDataResponse>>> OpenLabeledData([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ReviewerLabeledDataResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.OpenLabeledDataAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("tasks/{taskId}/content")]
    public async Task<IActionResult> OpenDataItemContent([FromRoute] string taskId, [FromServices] IStorageService storageService, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized();
        }

        var result = await reviewerWorkflowService.GetTaskDataItemStorageAsync(userId, taskId, cancellationToken);
        if (!result.IsSuccess)
        {
            return result.Message == ErrorMessages.NotFound ? NotFound() : StatusCode(StatusCodes.Status403Forbidden);
        }

        var opened = await storageService.OpenReadAsync(result.Data!.StorageProvider, result.Data!.ObjectKey, cancellationToken);
        if (opened is null)
        {
            return NotFound();
        }

        return File(opened.Value.Stream, opened.Value.ContentType, opened.Value.FileName);
    }

    [HttpGet("tasks/{taskId}/guideline-comparison")]
    public async Task<ActionResult<ServiceResponse<GuidelineComparisonResponse>>> CompareWithGuideline([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<GuidelineComparisonResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.CompareWithGuidelineAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("tasks/{taskId}/consistency-validation")]
    public async Task<ActionResult<ServiceResponse<LabelConsistencyValidationResponse>>> ValidateLabelConsistency([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelConsistencyValidationResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.ValidateLabelConsistencyAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/approve")]
    public async Task<ActionResult<ServiceResponse<bool>>> ApproveLabeledData([FromRoute] string taskId, [FromBody] ApproveLabeledDataRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.ApproveLabeledDataAsync(userId, taskId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/return")]
    public async Task<ActionResult<ServiceResponse<bool>>> ReturnLabelWithFeedback([FromRoute] string taskId, [FromBody] ReturnLabelWithFeedbackRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.ReturnLabelWithFeedbackAsync(userId, taskId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("error-types")]
    public async Task<ActionResult<ServiceResponse<List<ReviewerErrorTypeResponse>>>> SelectErrorType()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<ReviewerErrorTypeResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.GetErrorTypesAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("reviews/{reviewId}/errors")]
    public async Task<ActionResult<ServiceResponse<bool>>> CreateErrorRecord([FromRoute] string reviewId, [FromBody] CreateReviewErrorRecordRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.CreateErrorRecordAsync(userId, reviewId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("reviews/{reviewId}/errors")]
    public async Task<ActionResult<ServiceResponse<bool>>> UpdateErrorRecord([FromRoute] string reviewId, [FromBody] UpdateReviewErrorRecordRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.UpdateErrorRecordAsync(userId, reviewId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("error-statistics")]
    public async Task<ActionResult<ServiceResponse<ReviewerErrorStatisticsResponse>>> ViewErrorStatistics([FromQuery] string? projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ReviewerErrorStatisticsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await reviewerWorkflowService.GetErrorStatisticsAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }
}