using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;
using DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;
using DataLabellingSupportSystem.Api.DTOs.Responses.Projects;
using DataLabellingSupportSystem.Api.DTOs.Responses.Reviews;

namespace DataLabellingSupportSystem.Api.Services.Reviews;

public interface IReviewerWorkflowService
{
    Task<ServiceResponse<List<MyProjectSummaryResponse>>> GetMyProjectsAsync(string reviewerUserId);
    Task<ServiceResponse<List<ReviewerSubmittedTaskResponse>>> GetSubmittedTasksAsync(string reviewerUserId, string? projectId = null);
    Task<ServiceResponse<ReviewerLabeledDataResponse>> OpenLabeledDataAsync(string reviewerUserId, string taskId);
    Task<ServiceResponse<TaskDataItemStorageResponse>> GetTaskDataItemStorageAsync(string reviewerUserId, string taskId, CancellationToken cancellationToken);
    Task<ServiceResponse<GuidelineComparisonResponse>> CompareWithGuidelineAsync(string reviewerUserId, string taskId);
    Task<ServiceResponse<LabelConsistencyValidationResponse>> ValidateLabelConsistencyAsync(string reviewerUserId, string taskId);
    Task<ServiceResponse<bool>> ApproveLabeledDataAsync(string reviewerUserId, string taskId, ApproveLabeledDataRequest request);
    Task<ServiceResponse<bool>> ReturnLabelWithFeedbackAsync(string reviewerUserId, string taskId, ReturnLabelWithFeedbackRequest request);

    Task<ServiceResponse<List<ReviewerErrorTypeResponse>>> GetErrorTypesAsync(string reviewerUserId);
    Task<ServiceResponse<bool>> CreateErrorRecordAsync(string reviewerUserId, string reviewId, CreateReviewErrorRecordRequest request);
    Task<ServiceResponse<bool>> UpdateErrorRecordAsync(string reviewerUserId, string reviewId, UpdateReviewErrorRecordRequest request);
    Task<ServiceResponse<ReviewerErrorStatisticsResponse>> GetErrorStatisticsAsync(string reviewerUserId, string? projectId);
}