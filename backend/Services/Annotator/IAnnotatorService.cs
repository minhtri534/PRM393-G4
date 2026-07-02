using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;

namespace DataLabellingSupportSystem.Api.Services.Annotator;

public interface IAnnotatorService
{
    Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string userId);
    Task<ServiceResponse<List<AnnotatorTaskSummaryResponse>>> GetMyTasksAsync(string userId, string? projectId = null);
    Task<ServiceResponse<bool>> AcceptTaskAsync(string userId, string taskId);
    Task<ServiceResponse<bool>> RejectTaskAsync(string userId, string taskId, RejectTaskRequest request);
    Task<ServiceResponse<bool>> StartTaskAsync(string userId, string taskId);
    Task<ServiceResponse<List<AnnotatorTaskItemResponse>>> GetTaskItemsAsync(string userId, string taskId);
    Task<ServiceResponse<List<LabelResponse>>> GetTaskLabelsAsync(string userId, string taskId);
    Task<ServiceResponse<ProjectGuidelineResponse>> GetTaskGuidelineAsync(string userId, string taskId);
    Task<ServiceResponse<TaskDataItemStorageResponse>> GetTaskDataItemStorageAsync(string userId, string taskId, CancellationToken cancellationToken);
    Task<ServiceResponse<List<AnnotatorAnnotationResponse>>> GetTaskAnnotationsAsync(string userId, string taskId);
    Task<ServiceResponse<AnnotatorAnnotationResponse>> CreateTaskAnnotationAsync(string userId, string taskId, CreateTaskAnnotationRequest request);
    Task<ServiceResponse<AnnotatorAnnotationResponse>> UpdateTaskAnnotationAsync(string userId, string taskId, string annotationId, UpdateTaskAnnotationRequest request);
    Task<ServiceResponse<bool>> DeleteTaskAnnotationAsync(string userId, string taskId, string annotationId);
    Task<ServiceResponse<bool>> SaveTaskAnnotationsDraftAsync(string userId, string taskId, UpsertTaskItemAnnotationsRequest request);
    Task<ServiceResponse<bool>> SubmitTaskAnnotationsAsync(string userId, string taskId, UpsertTaskItemAnnotationsRequest request);
    Task<ServiceResponse<AnnotatorReviewFeedbackResponse>> GetTaskReviewFeedbackAsync(string userId, string taskId);
    Task<ServiceResponse<List<AnnotatorReviewErrorCategoryResponse>>> GetReviewErrorCategoriesAsync(string userId, string reviewId);
    Task<ServiceResponse<bool>> AddCommentToReviewerAsync(string userId, string reviewId, AddReviewerCommentRequest request);
    Task<ServiceResponse<bool>> AcceptAiSuggestionAsync(string userId, string taskId, string predictionId);
    Task<ServiceResponse<bool>> RejectAiSuggestionAsync(string userId, string taskId, string predictionId, RejectAiSuggestionRequest request);
}
