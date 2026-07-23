using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Extensions;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using DataLabellingSupportSystem.Api.DTOs.Requests.Notifications;
using DataLabellingSupportSystem.Api.DTOs.Requests.Users;
using DataLabellingSupportSystem.Api.DTOs.Responses.Manager;
using DataLabellingSupportSystem.Api.DTOs.Responses.Users;
using DataLabellingSupportSystem.Api.Services.Manager;
using DataLabellingSupportSystem.Api.Services.Storage;
using DataLabellingSupportSystem.Api.Services.Users;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Cryptography;

namespace DataLabellingSupportSystem.Api.Controllers;

[ApiController]
[Route("api/manager")]
[Authorize(Roles = "Admin,Manager")]
public sealed class ManagerController(
    IManagerService managerService,
    IStorageService storageService,
    IUsersService usersService) : ControllerBase
{
    [HttpGet("projects")]
    public async Task<ActionResult<ServiceResponse<List<ProjectResponse>>>> GetProjects()
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<ProjectResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetProjectsAsync(userId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> GetProjectById([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetProjectByIdAsync(userId, projectId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPost("projects")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> CreateProject([FromBody] CreateProjectRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateProjectAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("projects/{projectId}")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> UpdateProject([FromRoute] string projectId, [FromBody] UpdateProjectRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateProjectAsync(userId, projectId, request);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("projects/{projectId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteProject([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DeleteProjectAsync(userId, projectId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPatch("projects/{projectId}/status")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> ChangeProjectStatus([FromRoute] string projectId, [FromBody] UpdateProjectRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateProjectAsync(userId, projectId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("projects/{projectId}/archive")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> ArchiveProject([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var current = await managerService.GetProjectByIdAsync(userId, projectId);
        if (!current.IsSuccess || current.Data is null)
        {
            return current.Message == ErrorMessages.NotFound ? NotFound(current) : BadRequest(current);
        }

        var result = await managerService.UpdateProjectAsync(
            userId,
            projectId,
            new UpdateProjectRequest(current.Data.Name, current.Data.Guideline, 9));

        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("project-roles")]
    public async Task<ActionResult<ServiceResponse<UserProjectRoleResponse>>> AssignUserProjectRole([FromBody] AssignUserProjectRoleRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UserProjectRoleResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.AssignUserProjectRoleAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("projects/{projectId}/notifications")]
    public async Task<ActionResult<ServiceResponse<int>>> SendProjectNotification(
        [FromRoute] string projectId,
        [FromBody] SendProjectNotificationRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.SendProjectNotificationAsync(userId, projectId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/project-roles")]
    public async Task<ActionResult<ServiceResponse<List<UserProjectRoleResponse>>>> GetProjectRoles([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<UserProjectRoleResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetProjectRolesAsync(userId, projectId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("projects/{projectId}/project-roles/{userId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> RemoveProjectRole([FromRoute] string projectId, [FromRoute] string userId)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<List<UserProjectRoleResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.RemoveProjectRole(actorUserId, projectId, userId);
        
        if (result.IsSuccess) {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPost("dataset-versions")]
    public async Task<ActionResult<ServiceResponse<DatasetVersionResponse>>> CreateDatasetVersion([FromBody] CreateDatasetVersionRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<DatasetVersionResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateDatasetVersionAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("datasets")]
    public async Task<ActionResult<ServiceResponse<DatasetResponse>>> CreateDataset([FromBody] CreateDatasetRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<DatasetResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateDatasetAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/datasets")]
    public async Task<ActionResult<ServiceResponse<List<DatasetResponse>>>> GetDatasets([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<DatasetResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetDatasetsAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("datasets/{datasetId}")]
    public async Task<ActionResult<ServiceResponse<DatasetResponse>>> GetDatasetById([FromRoute] string datasetId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<DatasetResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetDatasetByIdAsync(userId, datasetId);
        return result.IsSuccess ? Ok(result) : result.Message == ErrorMessages.NotFound ? NotFound(result) : BadRequest(result);
    }

    [HttpPut("datasets/{datasetId}")]
    public async Task<ActionResult<ServiceResponse<DatasetResponse>>> UpdateDataset([FromRoute] string datasetId, [FromBody] UpdateDatasetRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<DatasetResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateDatasetAsync(userId, datasetId, request);
        return result.IsSuccess ? Ok(result) : result.Message == ErrorMessages.NotFound ? NotFound(result) : BadRequest(result);
    }

    [HttpDelete("datasets/{datasetId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteDataset([FromRoute] string datasetId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DeleteDatasetAsync(userId, datasetId);
        return result.IsSuccess ? Ok(result) : result.Message == ErrorMessages.NotFound ? NotFound(result) : BadRequest(result);
    }

    [HttpPost("datasets/upload")]
    public async Task<ActionResult<ServiceResponse<UploadDatasetItemsResponse>>> UploadDataset([FromBody] UploadDatasetItemsRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UploadDatasetItemsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UploadDatasetItemsAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("datasets/upload-files")]
    [Consumes("multipart/form-data")]
    public async Task<ActionResult<ServiceResponse<UploadDatasetItemsResponse>>> UploadDatasetFiles(
        [FromForm] string datasetId,
        [FromForm] List<IFormFile> files,
        CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UploadDatasetItemsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var normalizedDatasetId = (datasetId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalizedDatasetId))
        {
            return BadRequest(ServiceResponse<UploadDatasetItemsResponse>.Failure("Invalid payload", ["datasetId is required"]));
        }

        if (files is null || files.Count == 0)
        {
            return BadRequest(ServiceResponse<UploadDatasetItemsResponse>.Failure("Invalid payload", ["At least one file is required"]));
        }

        var items = new List<UploadDatasetItemDto>(files.Count);

        foreach (var file in files)
        {
            if (file is null || file.Length <= 0)
            {
                return BadRequest(ServiceResponse<UploadDatasetItemsResponse>.Failure("Invalid file", ["Uploaded file must not be empty"]));
            }

            await using var source = file.OpenReadStream();
            using var ms = new MemoryStream();
            await source.CopyToAsync(ms, cancellationToken);

            var bytes = ms.ToArray();
            if (!ImageSizeHelper.TryGetImageSize(bytes, out var width, out var height))
            {
                return BadRequest(ServiceResponse<UploadDatasetItemsResponse>.Failure("Invalid image", [$"Cannot read image size from file '{file.FileName}'"]));
            }

            var extension = Path.GetExtension(file.FileName);
            if (string.IsNullOrWhiteSpace(extension))
            {
                extension = ".bin";
            }

            var objectKey = $"uploads/{normalizedDatasetId}/{DateTime.UtcNow:yyyyMMdd}/{Guid.NewGuid():N}{extension.ToLowerInvariant()}";

            using var contentStream = new MemoryStream(bytes, writable: false);
            var saved = await storageService.SaveAsync("Local", objectKey, contentStream, cancellationToken);
            if (!saved)
            {
                return BadRequest(ServiceResponse<UploadDatasetItemsResponse>.Failure("Upload failed", [$"Cannot save file '{file.FileName}'"]));
            }

            var checksum = Convert.ToHexString(SHA256.HashData(bytes)).ToLowerInvariant();

            items.Add(new UploadDatasetItemDto(
                ObjectKey: objectKey,
                OriginalWidth: width,
                OriginalHeight: height,
                DataType: "Image",
                Checksum: checksum,
                StorageProvider: "Local"));
        }

        var result = await managerService.UploadDatasetItemsAsync(
            userId,
            new UploadDatasetItemsRequest(normalizedDatasetId, items));

        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("datasets/import-external")]
    public async Task<ActionResult<ServiceResponse<UploadDatasetItemsResponse>>> ImportDatasetExternal([FromBody] ImportDatasetFromExternalRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<UploadDatasetItemsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.ImportDatasetFromExternalAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("dataset-versions/{versionId}/restore")]
    public async Task<ActionResult<ServiceResponse<DatasetVersionResponse>>> RestoreDatasetVersion([FromRoute] string versionId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<DatasetVersionResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.RestoreDatasetVersionAsync(userId, versionId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("labels")]
    public async Task<ActionResult<ServiceResponse<LabelResponse>>> CreateLabel([FromBody] CreateLabelRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateLabelAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/labels")]
    public async Task<ActionResult<ServiceResponse<List<LabelResponse>>>> GetLabels([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<LabelResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetLabelsAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("labels/{labelId}")]
    public async Task<ActionResult<ServiceResponse<LabelResponse>>> UpdateLabel([FromRoute] string labelId, [FromBody] UpdateLabelRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateLabelAsync(userId, labelId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpDelete("labels/{labelId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteLabel([FromRoute] string labelId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DeleteLabelAsync(userId, labelId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("label-categories")]
    public async Task<ActionResult<ServiceResponse<LabelCategoryResponse>>> CreateLabelCategory([FromBody] CreateLabelCategoryRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelCategoryResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateLabelCategoryAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/label-categories")]
    public async Task<ActionResult<ServiceResponse<List<LabelCategoryResponse>>>> GetLabelCategories([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<LabelCategoryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetLabelCategoriesAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("label-categories/{categoryId}")]
    public async Task<ActionResult<ServiceResponse<LabelCategoryResponse>>> UpdateLabelCategory([FromRoute] string categoryId, [FromBody] UpdateLabelCategoryRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelCategoryResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateLabelCategoryAsync(userId, categoryId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpDelete("label-categories/{categoryId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteLabelCategory([FromRoute] string categoryId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DeleteLabelCategoryAsync(userId, categoryId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("annotation-types")]
    public async Task<ActionResult<ServiceResponse<AnnotationTypeResponse>>> CreateAnnotationType([FromBody] CreateAnnotationTypeRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AnnotationTypeResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateAnnotationTypeAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/annotation-types")]
    public async Task<ActionResult<ServiceResponse<List<AnnotationTypeResponse>>>> GetAnnotationTypes([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotationTypeResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetAnnotationTypesAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("annotation-types/{annotationTypeId}")]
    public async Task<ActionResult<ServiceResponse<AnnotationTypeResponse>>> UpdateAnnotationType([FromRoute] string annotationTypeId, [FromBody] UpdateAnnotationTypeRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<AnnotationTypeResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateAnnotationTypeAsync(userId, annotationTypeId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpDelete("annotation-types/{annotationTypeId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteAnnotationType([FromRoute] string annotationTypeId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DeleteAnnotationTypeAsync(userId, annotationTypeId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPatch("projects/{projectId}/guideline")]
    public async Task<ActionResult<ServiceResponse<ProjectResponse>>> UpdateGuideline([FromRoute] string projectId, [FromBody] UpdateProjectGuidelineRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ProjectResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.UpdateProjectGuidelineAsync(userId, projectId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> CreateTask([FromBody] CreateTaskRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateTaskAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/bulk-create-by-dataset")]
    public async Task<ActionResult<ServiceResponse<int>>> BulkCreateTasksByDataset([FromBody] BulkCreateTasksByDatasetRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.BulkCreateTasksByDatasetAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/assign")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> AssignTask([FromRoute] string taskId, [FromBody] AssignTaskRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.AssignTaskAsync(userId, taskId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/bulk-assign")]
    public async Task<ActionResult<ServiceResponse<int>>> BulkAssignTasks([FromBody] BulkAssignTasksRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<int>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.BulkAssignTasksAsync(userId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/reassign")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> ReassignTask([FromRoute] string taskId, [FromBody] AssignTaskRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.ReassignTaskAsync(userId, taskId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/pause")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> PauseTask([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.PauseTaskAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/resume")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> ResumeTask([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.ResumeTaskAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/cancel")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> CancelTask([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CancelTaskAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPost("tasks/{taskId}/relabel")]
    public async Task<ActionResult<ServiceResponse<TaskResponse>>> RequestRelabeling([FromRoute] string taskId, [FromBody] RequestRelabelingRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.RequestRelabelingAsync(userId, taskId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/tasks/progress")]
    public async Task<ActionResult<ServiceResponse<TaskProgressResponse>>> GetTaskProgress([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<TaskProgressResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetTaskProgressAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/tasks")]
    public async Task<ActionResult<ServiceResponse<List<TaskResponse>>>> GetProjectTasks([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<TaskResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetProjectTasksAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("tasks/{taskId}/history")]
    public async Task<ActionResult<ServiceResponse<List<TaskHistoryResponse>>>> GetTaskHistory([FromRoute] string taskId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<TaskHistoryResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetTaskHistoryAsync(userId, taskId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/monitoring/overview")]
    public async Task<ActionResult<ServiceResponse<LabelingProgressOverviewResponse>>> GetLabelingOverview([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<LabelingProgressOverviewResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetLabelingProgressOverviewAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/monitoring/annotator-performance")]
    public async Task<ActionResult<ServiceResponse<List<AnnotatorPerformanceResponse>>>> GetAnnotatorPerformance([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<AnnotatorPerformanceResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetAnnotatorPerformanceAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/monitoring/review-stats")]
    public async Task<ActionResult<ServiceResponse<ReviewStatisticsResponse>>> GetReviewStats([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ReviewStatisticsResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetReviewStatisticsAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/monitoring/inconsistent-labels")]
    public async Task<ActionResult<ServiceResponse<List<InconsistentLabelResponse>>>> GetInconsistentLabels([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<InconsistentLabelResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.DetectInconsistentLabelsAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("projects/{projectId}/monitoring/quality-report")]
    public async Task<ActionResult<ServiceResponse<QualityReportResponse>>> ExportQualityReport([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<QualityReportResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.ExportQualityReportAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("datasets/{datasetId}/versions")]
    public async Task<ActionResult<ServiceResponse<List<DatasetVersionResponse>>>> GetDatasetVersions([FromRoute] string datasetId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<DatasetVersionResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetDatasetVersionsAsync(userId, datasetId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPost("exports")]
    public async Task<ActionResult<ServiceResponse<ExportResponse>>> CreateExport([FromBody] CreateExportRequest request)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ExportResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.CreateExportAsync(userId, request);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpGet("projects/{projectId}/exports")]
    public async Task<ActionResult<ServiceResponse<List<ExportResponse>>>> GetProjectExports([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<List<ExportResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetProjectExportsAsync(userId, projectId);

        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpGet("projects/{projectId}/exports/validate")]
    public async Task<ActionResult<ServiceResponse<ExportValidationResponse>>> ValidateApprovedData([FromRoute] string projectId)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ExportValidationResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.ValidateApprovedDataAsync(userId, projectId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("exports/{exportId}/download")]
    public async Task<IActionResult> DownloadExport([FromRoute] string exportId, CancellationToken cancellationToken)
    {
        var userId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(userId))
        {
            return Unauthorized(ServiceResponse<ExportDownloadInfoResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var info = await managerService.GetExportDownloadInfoAsync(userId, exportId);
        if (!info.IsSuccess || info.Data is null)
        {
            return info.Message == ErrorMessages.NotFound ? NotFound(info) : BadRequest(info);
        }

        var opened = await storageService.OpenReadAsync(info.Data.StorageProvider, info.Data.ObjectKey, cancellationToken);
        if (opened is null)
        {
            return NotFound(ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Export file not found"]));
        }

        return File(opened.Value.Stream, opened.Value.ContentType, info.Data.FileName);
    }

    [HttpGet("activity-logs")]
    public async Task<ActionResult<ServiceResponse<List<ActivityLogResponse>>>> GetActivityLogs(
        [FromQuery] string? projectId,
        [FromQuery] string? userId,
        [FromQuery] int page = 1,
        [FromQuery] int pageSize = 50)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<List<ActivityLogResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await managerService.GetActivityLogsAsync(actorUserId, projectId, userId, page, pageSize);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("users")]
    public async Task<ActionResult<ServiceResponse<List<UserResponse>>>> GetUsers()
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<List<UserResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.GetAllAsync(actorUserId);
        return this.ToOkOrBadRequest(result);
    }

    [HttpGet("users/{userId}")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> GetUserById([FromRoute] string userId)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.GetByIdAsync(actorUserId, userId);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpPost("users")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> CreateUser([FromBody] CreateUserRequest request)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.CreateAsync(actorUserId, request);
        return this.ToOkOrBadRequest(result);
    }

    [HttpPut("users/{userId}")]
    public async Task<ActionResult<ServiceResponse<UserResponse>>> UpdateUser(
        [FromRoute] string userId,
        [FromBody] UpdateUserRequest request)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<UserResponse>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.UpdateAsync(actorUserId, userId, request);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }

    [HttpDelete("users/{userId}")]
    public async Task<ActionResult<ServiceResponse<bool>>> DeleteUser([FromRoute] string userId)
    {
        var actorUserId = User.GetUserId();
        if (string.IsNullOrWhiteSpace(actorUserId))
        {
            return Unauthorized(ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing user id claim"]));
        }

        var result = await usersService.DeleteAsync(actorUserId, userId);
        if (result.IsSuccess)
        {
            return Ok(result);
        }

        return result.Message == ErrorMessages.NotFound
            ? NotFound(result)
            : BadRequest(result);
    }
}
