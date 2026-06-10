using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using DataLabellingSupportSystem.Api.DTOs.Responses.Manager;

namespace DataLabellingSupportSystem.Api.Services.Manager;

public interface IManagerService
{
    Task<ServiceResponse<List<ProjectResponse>>> GetProjectsAsync(string actorUserId);
    Task<ServiceResponse<ProjectResponse>> GetProjectByIdAsync(string actorUserId, string projectId);
    Task<ServiceResponse<ProjectResponse>> CreateProjectAsync(string actorUserId, CreateProjectRequest request);
    Task<ServiceResponse<ProjectResponse>> UpdateProjectAsync(string actorUserId, string projectId, UpdateProjectRequest request);
    Task<ServiceResponse<bool>> DeleteProjectAsync(string actorUserId, string projectId);

    Task<ServiceResponse<UserProjectRoleResponse>> AssignUserProjectRoleAsync(string actorUserId, AssignUserProjectRoleRequest request);
    Task<ServiceResponse<List<UserProjectRoleResponse>>> GetProjectRolesAsync(string actorUserId, string projectId);

    Task<ServiceResponse<DatasetVersionResponse>> CreateDatasetVersionAsync(string actorUserId, CreateDatasetVersionRequest request);
    Task<ServiceResponse<List<DatasetVersionResponse>>> GetDatasetVersionsAsync(string actorUserId, string datasetId);

    Task<ServiceResponse<ExportResponse>> CreateExportAsync(string currentUserId, CreateExportRequest request);
    Task<ServiceResponse<List<ExportResponse>>> GetProjectExportsAsync(string actorUserId, string projectId);

    Task<ServiceResponse<List<ActivityLogResponse>>> GetActivityLogsAsync(string actorUserId, string? projectId, string? userId, int page, int pageSize);

    Task<ServiceResponse<DatasetResponse>> CreateDatasetAsync(string actorUserId, CreateDatasetRequest request);
    Task<ServiceResponse<List<DatasetResponse>>> GetDatasetsAsync(string actorUserId, string projectId);
    Task<ServiceResponse<DatasetResponse>> GetDatasetByIdAsync(string actorUserId, string datasetId);
    Task<ServiceResponse<DatasetResponse>> UpdateDatasetAsync(string actorUserId, string datasetId, UpdateDatasetRequest request);
    Task<ServiceResponse<bool>> DeleteDatasetAsync(string actorUserId, string datasetId);
    Task<ServiceResponse<UploadDatasetItemsResponse>> UploadDatasetItemsAsync(string actorUserId, UploadDatasetItemsRequest request);
    Task<ServiceResponse<UploadDatasetItemsResponse>> ImportDatasetFromExternalAsync(string actorUserId, ImportDatasetFromExternalRequest request);
    Task<ServiceResponse<DatasetVersionResponse>> RestoreDatasetVersionAsync(string actorUserId, string versionId);

    Task<ServiceResponse<LabelResponse>> CreateLabelAsync(string actorUserId, CreateLabelRequest request);
    Task<ServiceResponse<List<LabelResponse>>> GetLabelsAsync(string actorUserId, string projectId);
    Task<ServiceResponse<LabelResponse>> UpdateLabelAsync(string actorUserId, string labelId, UpdateLabelRequest request);
    Task<ServiceResponse<bool>> DeleteLabelAsync(string actorUserId, string labelId);
    Task<ServiceResponse<LabelCategoryResponse>> CreateLabelCategoryAsync(string actorUserId, CreateLabelCategoryRequest request);
    Task<ServiceResponse<List<LabelCategoryResponse>>> GetLabelCategoriesAsync(string actorUserId, string projectId);
    Task<ServiceResponse<LabelCategoryResponse>> UpdateLabelCategoryAsync(string actorUserId, string categoryId, UpdateLabelCategoryRequest request);
    Task<ServiceResponse<bool>> DeleteLabelCategoryAsync(string actorUserId, string categoryId);
    Task<ServiceResponse<AnnotationTypeResponse>> CreateAnnotationTypeAsync(string actorUserId, CreateAnnotationTypeRequest request);
    Task<ServiceResponse<List<AnnotationTypeResponse>>> GetAnnotationTypesAsync(string actorUserId, string projectId);
    Task<ServiceResponse<AnnotationTypeResponse>> UpdateAnnotationTypeAsync(string actorUserId, string annotationTypeId, UpdateAnnotationTypeRequest request);
    Task<ServiceResponse<bool>> DeleteAnnotationTypeAsync(string actorUserId, string annotationTypeId);
    Task<ServiceResponse<ProjectResponse>> UpdateProjectGuidelineAsync(string actorUserId, string projectId, UpdateProjectGuidelineRequest request);

    Task<ServiceResponse<TaskResponse>> CreateTaskAsync(string actorUserId, CreateTaskRequest request);
    Task<ServiceResponse<int>> BulkCreateTasksByDatasetAsync(string actorUserId, BulkCreateTasksByDatasetRequest request);
    Task<ServiceResponse<TaskResponse>> AssignTaskAsync(string actorUserId, string taskId, AssignTaskRequest request);
    Task<ServiceResponse<int>> BulkAssignTasksAsync(string actorUserId, BulkAssignTasksRequest request);
    Task<ServiceResponse<TaskResponse>> ReassignTaskAsync(string actorUserId, string taskId, AssignTaskRequest request);
    Task<ServiceResponse<TaskResponse>> PauseTaskAsync(string actorUserId, string taskId);
    Task<ServiceResponse<TaskResponse>> ResumeTaskAsync(string actorUserId, string taskId);
    Task<ServiceResponse<TaskResponse>> CancelTaskAsync(string actorUserId, string taskId);
    Task<ServiceResponse<TaskResponse>> RequestRelabelingAsync(string actorUserId, string taskId, RequestRelabelingRequest request);
    Task<ServiceResponse<TaskProgressResponse>> GetTaskProgressAsync(string actorUserId, string projectId);
    Task<ServiceResponse<List<TaskResponse>>> GetProjectTasksAsync(string actorUserId, string projectId);
    Task<ServiceResponse<List<TaskHistoryResponse>>> GetTaskHistoryAsync(string actorUserId, string taskId);

    Task<ServiceResponse<LabelingProgressOverviewResponse>> GetLabelingProgressOverviewAsync(string actorUserId, string projectId);
    Task<ServiceResponse<List<AnnotatorPerformanceResponse>>> GetAnnotatorPerformanceAsync(string actorUserId, string projectId);
    Task<ServiceResponse<ReviewStatisticsResponse>> GetReviewStatisticsAsync(string actorUserId, string projectId);
    Task<ServiceResponse<List<InconsistentLabelResponse>>> DetectInconsistentLabelsAsync(string actorUserId, string projectId);
    Task<ServiceResponse<QualityReportResponse>> ExportQualityReportAsync(string actorUserId, string projectId);

    Task<ServiceResponse<ExportValidationResponse>> ValidateApprovedDataAsync(string actorUserId, string projectId);
    Task<ServiceResponse<ExportDownloadInfoResponse>> GetExportDownloadInfoAsync(string actorUserId, string exportId);
}
