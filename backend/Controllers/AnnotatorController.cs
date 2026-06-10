using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.Services.AiAssist;
using DataLabellingSupportSystem.Api.Services.Annotator;
using DataLabellingSupportSystem.Api.Services.Storage;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/annotator")]
[Authorize(Roles = "Annotator")]
public sealed class AnnotatorController(IAnnotatorService annotatorService, IStorageService storageService, IAiAssistService aiAssistService) : ControllerBase
{
    [HttpGet("tasks")]
    public async Task<ActionResult<ServiceResponse<List<AnnotatorTaskSummaryResponse>>>> GetMyTasks()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotatorTaskSummaryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetMyTasksAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/accept")]
    public async Task<ActionResult<ServiceResponse<bool>>> AcceptTask([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.AcceptTaskAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/reject")]
    public async Task<ActionResult<ServiceResponse<bool>>> RejectTask([FromRoute] string taskId, [FromBody] RejectTaskRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.RejectTaskAsync(userId, taskId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/start")]
    public async Task<ActionResult<ServiceResponse<bool>>> StartTask([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.StartTaskAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("tasks/{taskId}/items")]
    public async Task<ActionResult<ServiceResponse<List<AnnotatorTaskItemResponse>>>> GetTaskItems([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotatorTaskItemResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetTaskItemsAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("tasks/{taskId}/labels")]
    public async Task<ActionResult<ServiceResponse<List<LabelResponse>>>> GetTaskLabels([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<LabelResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetTaskLabelsAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("tasks/{taskId}/guideline")]
    public async Task<ActionResult<ServiceResponse<ProjectGuidelineResponse>>> GetTaskGuideline([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectGuidelineResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetTaskGuidelineAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("tasks/{taskId}/data-item/content")]
    public async Task<IActionResult> OpenDataItemContent([FromRoute] string taskId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized();
        }

        var dataItemResult = await annotatorService.GetTaskDataItemStorageAsync(userId, taskId, cancellationToken);
        if (!dataItemResult.IsSuccess)
        {
            return string.Equals(dataItemResult.Message, ErrorMessages.NotFound, StringComparison.Ordinal)
                ? NotFound()
                : StatusCode(StatusCodes.Status403Forbidden);
        }

        var opened = await storageService.OpenReadAsync(
            dataItemResult.Data!.StorageProvider,
            dataItemResult.Data!.ObjectKey,
            cancellationToken);
        if (opened is null)
        {
            return NotFound();
        }

        return File(opened.Value.Stream, opened.Value.ContentType, opened.Value.FileName);
    }

    [HttpGet("tasks/{taskId}/annotations")]
    public async Task<ActionResult<ServiceResponse<List<AnnotatorAnnotationResponse>>>> GetTaskAnnotations([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotatorAnnotationResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetTaskAnnotationsAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/annotations")]
    public async Task<ActionResult<ServiceResponse<AnnotatorAnnotationResponse>>> CreateTaskAnnotation(
        [FromRoute] string taskId,
        [FromBody] CreateTaskAnnotationRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AnnotatorAnnotationResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.CreateTaskAnnotationAsync(userId, taskId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPut("tasks/{taskId}/annotations/{annotationId}")]
    public async Task<ActionResult<ServiceResponse<AnnotatorAnnotationResponse>>> UpdateTaskAnnotation(
        [FromRoute] string taskId,
        [FromRoute] string annotationId,
        [FromBody] UpdateTaskAnnotationRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AnnotatorAnnotationResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.UpdateTaskAnnotationAsync(userId, taskId, annotationId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpDelete("tasks/{taskId}/annotations/{annotationId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteTaskAnnotation(
        [FromRoute] string taskId,
        [FromRoute] string annotationId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.DeleteTaskAnnotationAsync(userId, taskId, annotationId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPut("tasks/{taskId}/annotations/draft")]
    public async Task<ActionResult<ServiceResponse<bool>>> SaveDraft(
        [FromRoute] string taskId,
        [FromBody] UpsertTaskItemAnnotationsRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.SaveTaskAnnotationsDraftAsync(userId, taskId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/annotations/submit")]
    public async Task<ActionResult<ServiceResponse<bool>>> Submit(
        [FromRoute] string taskId,
        [FromBody] UpsertTaskItemAnnotationsRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.SubmitTaskAnnotationsAsync(userId, taskId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/ai-suggest")]
    public async Task<ActionResult<ServiceResponse<AiAssistSuggestResponse>>> AiSuggestBbox(
        [FromRoute] string taskId,
        [FromQuery] bool apply,
        [FromQuery] string? labelId,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AiAssistSuggestResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await aiAssistService.SuggestBboxAsync(userId, taskId, apply, labelId, cancellationToken);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("tasks/{taskId}/review-feedback")]
    public async Task<ActionResult<ServiceResponse<AnnotatorReviewFeedbackResponse>>> GetReviewFeedback([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AnnotatorReviewFeedbackResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetTaskReviewFeedbackAsync(userId, taskId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpGet("reviews/{reviewId}/error-categories")]
    public async Task<ActionResult<ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>>> GetReviewErrorCategories([FromRoute] string reviewId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.GetReviewErrorCategoriesAsync(userId, reviewId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("reviews/{reviewId}/comment")]
    public async Task<ActionResult<ServiceResponse<bool>>> AddCommentToReviewer(
        [FromRoute] string reviewId,
        [FromBody] AddReviewerCommentRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.AddCommentToReviewerAsync(userId, reviewId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/ai-suggestions/{predictionId}/accept")]
    public async Task<ActionResult<ServiceResponse<bool>>> AcceptAiSuggestion([FromRoute] string taskId, [FromRoute] string predictionId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.AcceptAiSuggestionAsync(userId, taskId, predictionId);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }

    [HttpPost("tasks/{taskId}/ai-suggestions/{predictionId}/reject")]
    public async Task<ActionResult<ServiceResponse<bool>>> RejectAiSuggestion(
        [FromRoute] string taskId,
        [FromRoute] string predictionId,
        [FromBody] RejectAiSuggestionRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await annotatorService.RejectAiSuggestionAsync(userId, taskId, predictionId, request);
        return this.ToOkOrStatusCode(result, StatusCodes.Status403Forbidden);
    }
}
