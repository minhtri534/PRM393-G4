using System.Text.Json;
using System.IO.Compression;
using System.Text;
using DataLabellingSupportSystem.Api.Common.Constants;
using DataLabellingSupportSystem.Api.Common.Results;
using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.DTOs.Requests.Manager;
using DataLabellingSupportSystem.Api.DTOs.Responses.Manager;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.Manager;

public sealed class ManagerService(
    AppDbContext dbContext,
    IHostEnvironment hostEnvironment,
    ILogger<ManagerService> logger,
    IOptions<StorageOptions> storageOptions) : IManagerService
{
    public async Task<ServiceResponse<List<ProjectResponse>>> GetProjectsAsync(string actorUserId)
    {
        var normalizedActorId = (actorUserId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalizedActorId))
        {
            return ServiceResponse<List<ProjectResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing actor user id"]);
        }

        if (await IsSystemAdminAsync(normalizedActorId))
        {
            var adminItems = await dbContext.Projects
                .AsNoTracking()
                .OrderByDescending(x => x.CreatedAt)
                .Select(x => new ProjectResponse(x.Id, x.Name, x.Guideline, x.Status, x.CreatedAt, x.UpdatedAt))
                .ToListAsync();

            return ServiceResponse<List<ProjectResponse>>.Success(adminItems, "OK");
        }

        var accessibleProjectIds = await dbContext.UserProjectRoles
            .AsNoTracking()
            .Where(x => x.UserId == normalizedActorId)
            .Select(x => x.ProjectId)
            .Distinct()
            .ToListAsync();

        var items = await dbContext.Projects
            .AsNoTracking()
            .Where(x => accessibleProjectIds.Contains(x.Id))
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new ProjectResponse(x.Id, x.Name, x.Guideline, x.Status, x.CreatedAt, x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<ProjectResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<ProjectResponse>> GetProjectByIdAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<ProjectResponse>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<ProjectResponse>.Failure(access.Message, access.Errors);
        }

        var item = await dbContext.Projects
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new ProjectResponse(x.Id, x.Name, x.Guideline, x.Status, x.CreatedAt, x.UpdatedAt))
            .FirstOrDefaultAsync();

        if (item is null)
        {
            return ServiceResponse<ProjectResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        return ServiceResponse<ProjectResponse>.Success(item, "OK");
    }

    public async Task<ServiceResponse<ProjectResponse>> CreateProjectAsync(string actorUserId, CreateProjectRequest request)
    {
        var name = (request.Name ?? string.Empty).Trim();
        var guideline = string.IsNullOrWhiteSpace(request.Guideline) ? null : request.Guideline.Trim();

        var existed = await dbContext.Projects
            .AsNoTracking()
            .AnyAsync(x => x.Name == name);

        if (existed)
        {
            return ServiceResponse<ProjectResponse>.Failure("Project already exists", ["Project name already exists"]);
        }

        var entity = new Project
        {
            Name = name,
            Guideline = guideline,
            Status = request.Status
        };

        dbContext.Projects.Add(entity);
        await dbContext.SaveChangesAsync();

        var actorRoleId = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == actorUserId)
            .Select(x => x.RoleId)
            .FirstOrDefaultAsync();

        if (!string.IsNullOrWhiteSpace(actorRoleId))
        {
            var membershipExists = await dbContext.UserProjectRoles
                .AsNoTracking()
                .AnyAsync(x => x.UserId == actorUserId && x.ProjectId == entity.Id && x.RoleId == actorRoleId);

            if (!membershipExists)
            {
                dbContext.UserProjectRoles.Add(new UserProjectRole
                {
                    UserId = actorUserId,
                    ProjectId = entity.Id,
                    RoleId = actorRoleId
                });
            }
        }

        await AddActivityLogAsync(actorUserId, "Manager.CreateProject", "projects", entity.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<ProjectResponse>.Success(
            new ProjectResponse(entity.Id, entity.Name, entity.Guideline, entity.Status, entity.CreatedAt, entity.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<ProjectResponse>> UpdateProjectAsync(string actorUserId, string projectId, UpdateProjectRequest request)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<ProjectResponse>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<ProjectResponse>.Failure(access.Message, access.Errors);
        }

        var entity = await dbContext.Projects.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<ProjectResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var name = (request.Name ?? string.Empty).Trim();
        var duplicateName = await dbContext.Projects
            .AsNoTracking()
            .AnyAsync(x => x.Id != id && x.Name == name);

        if (duplicateName)
        {
            return ServiceResponse<ProjectResponse>.Failure("Project already exists", ["Project name already exists"]);
        }

        entity.Name = name;
        entity.Guideline = string.IsNullOrWhiteSpace(request.Guideline) ? null : request.Guideline.Trim();
        entity.Status = request.Status;

        await AddActivityLogAsync(actorUserId, "Manager.UpdateProject", "projects", entity.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<ProjectResponse>.Success(
            new ProjectResponse(entity.Id, entity.Name, entity.Guideline, entity.Status, entity.CreatedAt, entity.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteProjectAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<bool>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var entity = await dbContext.Projects.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        dbContext.Projects.Remove(entity);
        await AddActivityLogAsync(actorUserId, "Manager.DeleteProject", "projects", entity.Id);

        try
        {
            await dbContext.SaveChangesAsync();
            return ServiceResponse<bool>.Success(true, "Deleted");
        }
        catch (DbUpdateException)
        {
            return ServiceResponse<bool>.Failure("Project is in use", ["Cannot delete project because it has related records"]);
        }
    }

    public async Task<ServiceResponse<UserProjectRoleResponse>> AssignUserProjectRoleAsync(string actorUserId, AssignUserProjectRoleRequest request)
    {
        var userId = (request.UserId ?? string.Empty).Trim();
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var roleId = (request.RoleId ?? string.Empty).Trim();

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<UserProjectRoleResponse>.Failure(access.Message, access.Errors);
        }

        var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId);
        if (user is null)
        {
            return ServiceResponse<UserProjectRoleResponse>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var project = await dbContext.Projects.AsNoTracking().FirstOrDefaultAsync(x => x.Id == projectId);
        if (project is null)
        {
            return ServiceResponse<UserProjectRoleResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var exists = await dbContext.UserProjectRoles
            .AsNoTracking()
            .AnyAsync(x => x.UserId == userId && x.ProjectId == projectId && x.RoleId == roleId);

        if (exists)
        {
            return ServiceResponse<UserProjectRoleResponse>.Failure("Assignment already exists", ["This user already has this role in the project"]);
        }

        var realRole = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId);

        var role = await dbContext.Roles.AsNoTracking().FirstOrDefaultAsync(x => x.Id == realRole.RoleId);
        if (role is null)
        {
            return ServiceResponse<UserProjectRoleResponse>.Failure(ErrorMessages.NotFound, ["Role not found"]);
        }

        var entity = new UserProjectRole
        {
            UserId = userId,
            ProjectId = projectId,
            RoleId = role.Id
        };

        dbContext.UserProjectRoles.Add(entity);

        await AddActivityLogAsync(actorUserId, "Manager.AssignUserProjectRole", "user_project_roles", $"{userId}:{projectId}:{roleId}");
        await dbContext.SaveChangesAsync();

        return ServiceResponse<UserProjectRoleResponse>.Success(
            new UserProjectRoleResponse(user.Id, user.Email, project.Id, project.Name, role.Id, role.Name),
            "Created");
    }

    public async Task<ServiceResponse<bool>> RemoveProjectRole(string actorUserId, string projectId, string userId)
    {
        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == userId);
        if (user is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["User not found"]);
        }

        var project = await dbContext.Projects.AsNoTracking().FirstOrDefaultAsync(x => x.Id == projectId);
        if (project is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var projectRole = await dbContext.UserProjectRoles.FirstOrDefaultAsync(x => x.UserId == userId && x.ProjectId == projectId);
        
        if (projectRole is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Project role not found"]);
        }

        try
        {
            dbContext.UserProjectRoles.Remove(projectRole);
            await dbContext.SaveChangesAsync();
            return ServiceResponse<bool>.Success(true, "Deleted");
        } catch
        {
            return ServiceResponse<bool>.Failure("An error occured");
        }
    }

    public async Task<ServiceResponse<List<UserProjectRoleResponse>>> GetProjectRolesAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<UserProjectRoleResponse>>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<UserProjectRoleResponse>>.Failure(access.Message, access.Errors);
        }

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == id);
        if (!projectExists)
        {
            return ServiceResponse<List<UserProjectRoleResponse>>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var items = await dbContext.UserProjectRoles
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .Join(dbContext.Users,
            x => x.UserId,
            y => y.Id,
            (x, y) => new UserProjectRoleResponse(
                x.UserId,
                x.User != null ? x.User.Email : string.Empty,
                x.ProjectId,
                x.Project != null ? x.Project.Name : string.Empty,
                y.RoleId,
                y.Role != null ? y.Role.Name : string.Empty))
            .ToListAsync();

        return ServiceResponse<List<UserProjectRoleResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<DatasetVersionResponse>> CreateDatasetVersionAsync(string actorUserId, CreateDatasetVersionRequest request)
    {
        var datasetId = (request.DatasetId ?? string.Empty).Trim();
        var versionName = (request.VersionName ?? string.Empty).Trim();

        var dataset = await dbContext.Datasets.AsNoTracking().FirstOrDefaultAsync(x => x.Id == datasetId);
        if (dataset is null)
        {
            return ServiceResponse<DatasetVersionResponse>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, dataset.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<DatasetVersionResponse>.Failure(access.Message, access.Errors);
        }

        var duplicated = await dbContext.DatasetVersions
            .AsNoTracking()
            .AnyAsync(x => x.DatasetId == datasetId && x.VersionName == versionName);

        if (duplicated)
        {
            return ServiceResponse<DatasetVersionResponse>.Failure("Version already exists", ["Version name already exists in this dataset"]);
        }

        var entity = new DatasetVersion
        {
            DatasetId = datasetId,
            VersionName = versionName
        };

        dbContext.DatasetVersions.Add(entity);

        await AddActivityLogAsync(actorUserId, "Manager.CreateDatasetVersion", "dataset_versions", datasetId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<DatasetVersionResponse>.Success(
            new DatasetVersionResponse(entity.Id, entity.DatasetId, entity.VersionName, entity.CreatedAt),
            "Created");
    }

    public async Task<ServiceResponse<List<DatasetVersionResponse>>> GetDatasetVersionsAsync(string actorUserId, string datasetId)
    {
        var id = (datasetId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<DatasetVersionResponse>>.Failure("Invalid dataset", ["Dataset id is required"]);
        }

        var dataset = await dbContext.Datasets.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (dataset is null)
        {
            return ServiceResponse<List<DatasetVersionResponse>>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, dataset.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<List<DatasetVersionResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.DatasetVersions
            .AsNoTracking()
            .Where(x => x.DatasetId == id)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new DatasetVersionResponse(x.Id, x.DatasetId, x.VersionName, x.CreatedAt))
            .ToListAsync();

        return ServiceResponse<List<DatasetVersionResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<ExportResponse>> CreateExportAsync(string currentUserId, CreateExportRequest request)
    {
        try
        {
            var projectId = (request.ProjectId ?? string.Empty).Trim();
            var format = (request.Format ?? string.Empty).Trim();
            var requestedExportPath = (request.ExportPath ?? string.Empty).Trim();
            var labelFormat = (request.LabelFormat ?? string.Empty).Trim();

            var project = await dbContext.Projects.AsNoTracking().FirstOrDefaultAsync(x => x.Id == projectId);
            if (project is null)
            {
                return ServiceResponse<ExportResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
            }

            var access = await EnsureProjectAccessAsync(currentUserId, projectId);
            if (access is not null)
            {
                return ServiceResponse<ExportResponse>.Failure(access.Message, access.Errors);
            }

            var user = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == currentUserId);
            if (user is null)
            {
                return ServiceResponse<ExportResponse>.Failure(ErrorMessages.Unauthorized, ["Current user not found"]);
            }

            var includeFieldsJson = JsonSerializer.Serialize(request.IncludeFields ?? []);
            var filtersJson = JsonSerializer.Serialize(request.Filters ?? new Dictionary<string, string>());

            var exportId = ObjectId.NewObjectId();
            var exportObjectKey = BuildExportObjectKey(projectId, exportId, requestedExportPath);
            
            byte[] exportedContent;
            if (string.Equals(format, "YOLO", StringComparison.OrdinalIgnoreCase))
            {
                logger.LogInformation("Building YOLO ZIP export for project {ProjectId}", projectId);
                exportedContent = await BuildApprovedExportYoloZipAsync(projectId);
            }
            else
            {
                logger.LogInformation("Building JSON export for project {ProjectId}", projectId);
                var json = await BuildApprovedExportJsonAsync(projectId, includeFieldsJson, filtersJson);
                exportedContent = Encoding.UTF8.GetBytes(json);
            }

            logger.LogInformation("Writing export file to {ObjectKey}", exportObjectKey);
            var writeSucceeded = await WriteExportFileAsync(exportObjectKey, exportedContent);
            if (!writeSucceeded)
            {
                return ServiceResponse<ExportResponse>.Failure("Export failed", ["Cannot write export file to local storage"]);
            }

            var entity = new Export
            {
                Id = exportId,
                ProjectId = projectId,
                Format = format,
                ExportedByUserId = currentUserId,
                ExportPath = exportObjectKey
            };

            entity.ExportConfig = new ExportConfig
            {
                ExportId = exportId,
                LabelFormat = labelFormat,
                IncludeFields = includeFieldsJson,
                Filters = filtersJson
            };

            logger.LogInformation("Saving export entity to database");
            dbContext.Exports.Add(entity);
            await AddActivityLogAsync(currentUserId, "Manager.CreateExport", "exports", entity.Id);
            await dbContext.SaveChangesAsync();

            return ServiceResponse<ExportResponse>.Success(
                new ExportResponse(
                    entity.Id,
                    entity.ProjectId,
                    project.Name,
                    entity.Format,
                    entity.ExportedByUserId,
                    user.Email,
                    entity.ExportPath,
                    entity.CreatedAt,
                    new ExportConfigResponse(entity.ExportConfig!.LabelFormat, entity.ExportConfig.IncludeFields, entity.ExportConfig.Filters)),
                "Created");
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled error in CreateExportAsync for project {ProjectId}", request.ProjectId);
            return ServiceResponse<ExportResponse>.Failure("Internal Server Error", [ex.Message]);
        }
    }

    public async Task<ServiceResponse<List<ExportResponse>>> GetProjectExportsAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<ExportResponse>>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<ExportResponse>>.Failure(access.Message, access.Errors);
        }

        var exists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == id);
        if (!exists)
        {
            return ServiceResponse<List<ExportResponse>>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var items = await dbContext.Exports
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new ExportResponse(
                x.Id,
                x.ProjectId,
                x.Project != null ? x.Project.Name : string.Empty,
                x.Format,
                x.ExportedByUserId,
                x.ExportedByUser != null ? x.ExportedByUser.Email : string.Empty,
                x.ExportPath,
                x.CreatedAt,
                new ExportConfigResponse(
                    x.ExportConfig != null ? x.ExportConfig.LabelFormat : string.Empty,
                    x.ExportConfig != null ? x.ExportConfig.IncludeFields : "[]",
                    x.ExportConfig != null ? x.ExportConfig.Filters : "{}")))
            .ToListAsync();

        return ServiceResponse<List<ExportResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<List<ActivityLogResponse>>> GetActivityLogsAsync(string actorUserId, string? projectId, string? userId, int page, int pageSize)
    {
        var normalizedProjectId = (projectId ?? string.Empty).Trim();
        var normalizedUserId = (userId ?? string.Empty).Trim();
        var normalizedActorUserId = (actorUserId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(normalizedActorUserId))
        {
            return ServiceResponse<List<ActivityLogResponse>>.Failure(ErrorMessages.Unauthorized, ["Missing actor user id"]);
        }

        var isAdmin = await IsSystemAdminAsync(normalizedActorUserId);

        if (!isAdmin)
        {
            if (string.IsNullOrWhiteSpace(normalizedProjectId))
            {
                return ServiceResponse<List<ActivityLogResponse>>.Failure(ErrorMessages.Forbidden, ["Non-admin must provide projectId"]);
            }

            var access = await EnsureProjectAccessAsync(normalizedActorUserId, normalizedProjectId);
            if (access is not null)
            {
                return ServiceResponse<List<ActivityLogResponse>>.Failure(access.Message, access.Errors);
            }
        }

        var query = dbContext.ActivityLogs.AsNoTracking().AsQueryable();

        if (!string.IsNullOrWhiteSpace(normalizedUserId))
        {
            query = query.Where(x => x.UserId == normalizedUserId);
        }

        if (!string.IsNullOrWhiteSpace(normalizedProjectId))
        {
            query = query.Where(x => x.TargetId == normalizedProjectId);
        }

        var skip = (Math.Max(1, page) - 1) * Math.Clamp(pageSize, 1, 200);
        var take = Math.Clamp(pageSize, 1, 200);

        var items = await query
            .OrderByDescending(x => x.CreatedAt)
            .Skip(skip)
            .Take(take)
            .Select(x => new ActivityLogResponse(
                x.Id,
                x.UserId,
                x.User != null ? x.User.Email : string.Empty,
                x.Action,
                x.TargetType,
                x.TargetId,
                x.CreatedAt))
            .ToListAsync();

        return ServiceResponse<List<ActivityLogResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<DatasetResponse>> CreateDatasetAsync(string actorUserId, CreateDatasetRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var project = await dbContext.Projects.AsNoTracking().FirstOrDefaultAsync(x => x.Id == projectId);
        if (project is null)
        {
            return ServiceResponse<DatasetResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<DatasetResponse>.Failure(access.Message, access.Errors);
        }

        var exists = await dbContext.Datasets.AsNoTracking().AnyAsync(x => x.ProjectId == projectId && x.Name == name);
        if (exists)
        {
            return ServiceResponse<DatasetResponse>.Failure("Dataset already exists", ["Dataset name already exists in project"]);
        }

        var entity = new Dataset
        {
            ProjectId = projectId,
            Name = name
        };

        dbContext.Datasets.Add(entity);
        await AddActivityLogAsync(actorUserId, "Manager.CreateDataset", "datasets", entity.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<DatasetResponse>.Success(
            new DatasetResponse(entity.Id, entity.ProjectId, project.Name, entity.Name, 0, entity.CreatedAt, entity.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<List<DatasetResponse>>> GetDatasetsAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<DatasetResponse>>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<DatasetResponse>>.Failure(access.Message, access.Errors);
        }

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == id);
        if (!projectExists)
        {
            return ServiceResponse<List<DatasetResponse>>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var items = await dbContext.Datasets
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new DatasetResponse(
                x.Id,
                x.ProjectId,
                x.Project != null ? x.Project.Name : string.Empty,
                x.Name,
                dbContext.DataItems.Count(d => d.DatasetId == x.Id),
                x.CreatedAt,
                x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<DatasetResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<DatasetResponse>> GetDatasetByIdAsync(string actorUserId, string datasetId)
    {
        var id = (datasetId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<DatasetResponse>.Failure("Invalid dataset", ["Dataset id is required"]);
        }

        var item = await dbContext.Datasets
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new DatasetResponse(
                x.Id,
                x.ProjectId,
                x.Project != null ? x.Project.Name : string.Empty,
                x.Name,
                dbContext.DataItems.Count(d => d.DatasetId == x.Id),
                x.CreatedAt,
                x.UpdatedAt))
            .FirstOrDefaultAsync();

        if (item is null)
        {
            return ServiceResponse<DatasetResponse>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, item.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<DatasetResponse>.Failure(access.Message, access.Errors);
        }

        return ServiceResponse<DatasetResponse>.Success(item, "OK");
    }

    public async Task<ServiceResponse<DatasetResponse>> UpdateDatasetAsync(string actorUserId, string datasetId, UpdateDatasetRequest request)
    {
        var id = (datasetId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var entity = await dbContext.Datasets.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<DatasetResponse>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<DatasetResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.Datasets
            .AsNoTracking()
            .AnyAsync(x => x.Id != id && x.ProjectId == entity.ProjectId && x.Name == name);

        if (duplicate)
        {
            return ServiceResponse<DatasetResponse>.Failure("Dataset already exists", ["Dataset name already exists in project"]);
        }

        entity.Name = name;
        await AddActivityLogAsync(actorUserId, "Manager.UpdateDataset", "datasets", entity.Id);
        await dbContext.SaveChangesAsync();

        var projectName = await dbContext.Projects.AsNoTracking().Where(x => x.Id == entity.ProjectId).Select(x => x.Name).FirstOrDefaultAsync() ?? string.Empty;
        var totalItems = await dbContext.DataItems.AsNoTracking().CountAsync(x => x.DatasetId == entity.Id);

        return ServiceResponse<DatasetResponse>.Success(
            new DatasetResponse(entity.Id, entity.ProjectId, projectName, entity.Name, totalItems, entity.CreatedAt, entity.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteDatasetAsync(string actorUserId, string datasetId)
    {
        var id = (datasetId ?? string.Empty).Trim();
        var entity = await dbContext.Datasets.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        dbContext.Datasets.Remove(entity);
        await AddActivityLogAsync(actorUserId, "Manager.DeleteDataset", "datasets", entity.Id);

        try
        {
            await dbContext.SaveChangesAsync();
            return ServiceResponse<bool>.Success(true, "Deleted");
        }
        catch (DbUpdateException)
        {
            return ServiceResponse<bool>.Failure("Dataset is in use", ["Cannot delete dataset because it has related records"]);
        }
    }

    public async Task<ServiceResponse<UploadDatasetItemsResponse>> UploadDatasetItemsAsync(string actorUserId, UploadDatasetItemsRequest request)
    {
        var datasetId = (request.DatasetId ?? string.Empty).Trim();

        var dataset = await dbContext.Datasets.AsNoTracking().FirstOrDefaultAsync(x => x.Id == datasetId);
        if (dataset is null)
        {
            return ServiceResponse<UploadDatasetItemsResponse>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, dataset.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<UploadDatasetItemsResponse>.Failure(access.Message, access.Errors);
        }

        var items = request.Items ?? [];
        if (items.Count == 0)
        {
            return ServiceResponse<UploadDatasetItemsResponse>.Failure("Invalid payload", ["At least one item is required"]);
        }

        var entities = items.Select(x => new DataItem
        {
            DatasetId = datasetId,
            ObjectKey = (x.ObjectKey ?? string.Empty).Trim(),
            OriginalWidth = x.OriginalWidth,
            OriginalHeight = x.OriginalHeight,
            DataType = string.IsNullOrWhiteSpace(x.DataType) ? "Image" : x.DataType.Trim(),
            Checksum = string.IsNullOrWhiteSpace(x.Checksum) ? null : x.Checksum.Trim(),
            StorageProvider = string.IsNullOrWhiteSpace(x.StorageProvider) ? "Local" : x.StorageProvider.Trim(),
            UploadedByUserId = actorUserId
        }).ToList();

        dbContext.DataItems.AddRange(entities);
        await AddActivityLogAsync(actorUserId, "Manager.UploadDataset", "datasets", datasetId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<UploadDatasetItemsResponse>.Success(
            new UploadDatasetItemsResponse(datasetId, entities.Count),
            "Created");
    }

    public async Task<ServiceResponse<UploadDatasetItemsResponse>> ImportDatasetFromExternalAsync(string actorUserId, ImportDatasetFromExternalRequest request)
    {
        var result = await UploadDatasetItemsAsync(actorUserId, new UploadDatasetItemsRequest(request.DatasetId, request.Items));
        if (!result.IsSuccess)
        {
            return result;
        }

        await AddActivityLogAsync(actorUserId, "Manager.ImportDatasetExternal", "datasets", request.DatasetId);
        await dbContext.SaveChangesAsync();
        return ServiceResponse<UploadDatasetItemsResponse>.Success(result.Data!, "Imported");
    }

    public async Task<ServiceResponse<DatasetVersionResponse>> RestoreDatasetVersionAsync(string actorUserId, string versionId)
    {
        var id = (versionId ?? string.Empty).Trim();
        var version = await dbContext.DatasetVersions.AsNoTracking().FirstOrDefaultAsync(x => x.Id == id);
        if (version is null)
        {
            return ServiceResponse<DatasetVersionResponse>.Failure(ErrorMessages.NotFound, ["Version not found"]);
        }

        var datasetProjectId = await dbContext.Datasets
            .AsNoTracking()
            .Where(x => x.Id == version.DatasetId)
            .Select(x => x.ProjectId)
            .FirstOrDefaultAsync();

        if (string.IsNullOrWhiteSpace(datasetProjectId))
        {
            return ServiceResponse<DatasetVersionResponse>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, datasetProjectId);
        if (access is not null)
        {
            return ServiceResponse<DatasetVersionResponse>.Failure(access.Message, access.Errors);
        }

        var restored = new DatasetVersion
        {
            DatasetId = version.DatasetId,
            VersionName = $"{version.VersionName}-restored-{DateTime.UtcNow:yyyyMMddHHmmss}"
        };

        dbContext.DatasetVersions.Add(restored);
        await AddActivityLogAsync(actorUserId, "Manager.RestoreDatasetVersion", "dataset_versions", restored.DatasetId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<DatasetVersionResponse>.Success(
            new DatasetVersionResponse(restored.Id, restored.DatasetId, restored.VersionName, restored.CreatedAt),
            "Restored");
    }

    public async Task<ServiceResponse<LabelResponse>> CreateLabelAsync(string actorUserId, CreateLabelRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();
        var categoryId = NormalizeOptionalId(request.CategoryId);
        var annotationTypeId = NormalizeOptionalId(request.AnnotationTypeId);

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == projectId);
        if (!projectExists)
        {
            return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<LabelResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.Labels.AsNoTracking().AnyAsync(x => x.ProjectId == projectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<LabelResponse>.Failure("Label already exists", ["Label name already exists in project"]);
        }

        if (!string.IsNullOrWhiteSpace(categoryId))
        {
            var categoryExists = await dbContext.LabelCategories.AsNoTracking().AnyAsync(x => x.Id == categoryId && x.ProjectId == projectId);
            if (!categoryExists)
            {
                return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Label category not found"]);
            }
        }

        if (!string.IsNullOrWhiteSpace(annotationTypeId))
        {
            var annotationTypeExists = await dbContext.AnnotationTypeDefinitions.AsNoTracking().AnyAsync(x => x.Id == annotationTypeId && x.ProjectId == projectId);
            if (!annotationTypeExists)
            {
                return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Annotation type not found"]);
            }
        }

        var entity = new Label
        {
            ProjectId = projectId,
            Name = name,
            YoloClassId = request.YoloClassId,
            CategoryId = categoryId,
            AnnotationTypeId = annotationTypeId
        };

        dbContext.Labels.Add(entity);
        await AddActivityLogAsync(actorUserId, "Manager.CreateLabel", "label_classes", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<LabelResponse>.Success(
            new LabelResponse(entity.Id, entity.ProjectId, entity.Name, entity.YoloClassId, entity.CategoryId, entity.AnnotationTypeId, entity.CreatedAt, entity.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<List<LabelResponse>>> GetLabelsAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<LabelResponse>>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<LabelResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.Labels
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderBy(x => x.YoloClassId)
            .Select(x => new LabelResponse(x.Id, x.ProjectId, x.Name, x.YoloClassId, x.CategoryId, x.AnnotationTypeId, x.CreatedAt, x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<LabelResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<LabelResponse>> UpdateLabelAsync(string actorUserId, string labelId, UpdateLabelRequest request)
    {
        var id = (labelId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();
        var categoryId = NormalizeOptionalId(request.CategoryId);
        var annotationTypeId = NormalizeOptionalId(request.AnnotationTypeId);

        var entity = await dbContext.Labels.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Label not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<LabelResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.Labels.AsNoTracking().AnyAsync(x => x.Id != id && x.ProjectId == entity.ProjectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<LabelResponse>.Failure("Label already exists", ["Label name already exists in project"]);
        }

        if (!string.IsNullOrWhiteSpace(categoryId))
        {
            var categoryExists = await dbContext.LabelCategories.AsNoTracking().AnyAsync(x => x.Id == categoryId && x.ProjectId == entity.ProjectId);
            if (!categoryExists)
            {
                return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Label category not found"]);
            }
        }

        if (!string.IsNullOrWhiteSpace(annotationTypeId))
        {
            var annotationTypeExists = await dbContext.AnnotationTypeDefinitions.AsNoTracking().AnyAsync(x => x.Id == annotationTypeId && x.ProjectId == entity.ProjectId);
            if (!annotationTypeExists)
            {
                return ServiceResponse<LabelResponse>.Failure(ErrorMessages.NotFound, ["Annotation type not found"]);
            }
        }

        entity.Name = name;
        entity.YoloClassId = request.YoloClassId;
        entity.CategoryId = categoryId;
        entity.AnnotationTypeId = annotationTypeId;

        await AddActivityLogAsync(actorUserId, "Manager.UpdateLabel", "label_classes", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<LabelResponse>.Success(
            new LabelResponse(entity.Id, entity.ProjectId, entity.Name, entity.YoloClassId, entity.CategoryId, entity.AnnotationTypeId, entity.CreatedAt, entity.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteLabelAsync(string actorUserId, string labelId)
    {
        var id = (labelId ?? string.Empty).Trim();
        var entity = await dbContext.Labels.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Label not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        dbContext.Labels.Remove(entity);
        await AddActivityLogAsync(actorUserId, "Manager.DeleteLabel", "label_classes", entity.ProjectId);

        try
        {
            await dbContext.SaveChangesAsync();
            return ServiceResponse<bool>.Success(true, "Deleted");
        }
        catch (DbUpdateException)
        {
            return ServiceResponse<bool>.Failure("Label is in use", ["Cannot delete label because it is referenced by annotations"]);
        }
    }

    public async Task<ServiceResponse<LabelCategoryResponse>> CreateLabelCategoryAsync(string actorUserId, CreateLabelCategoryRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == projectId);
        if (!projectExists)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.LabelCategories.AsNoTracking().AnyAsync(x => x.ProjectId == projectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure("Category already exists", ["Label category name already exists in project"]);
        }

        var entity = new LabelCategory
        {
            ProjectId = projectId,
            Name = name,
            Description = NormalizeOptionalText(request.Description)
        };

        dbContext.LabelCategories.Add(entity);
        await AddActivityLogAsync(actorUserId, "Manager.CreateLabelCategory", "label_categories", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<LabelCategoryResponse>.Success(
            new LabelCategoryResponse(entity.Id, entity.ProjectId, entity.Name, entity.Description, entity.CreatedAt, entity.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<List<LabelCategoryResponse>>> GetLabelCategoriesAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<LabelCategoryResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.LabelCategories
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderBy(x => x.Name)
            .Select(x => new LabelCategoryResponse(x.Id, x.ProjectId, x.Name, x.Description, x.CreatedAt, x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<LabelCategoryResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<LabelCategoryResponse>> UpdateLabelCategoryAsync(string actorUserId, string categoryId, UpdateLabelCategoryRequest request)
    {
        var id = (categoryId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var entity = await dbContext.LabelCategories.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure(ErrorMessages.NotFound, ["Label category not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.LabelCategories.AsNoTracking().AnyAsync(x => x.Id != id && x.ProjectId == entity.ProjectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<LabelCategoryResponse>.Failure("Category already exists", ["Label category name already exists in project"]);
        }

        entity.Name = name;
        entity.Description = NormalizeOptionalText(request.Description);

        await AddActivityLogAsync(actorUserId, "Manager.UpdateLabelCategory", "label_categories", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<LabelCategoryResponse>.Success(
            new LabelCategoryResponse(entity.Id, entity.ProjectId, entity.Name, entity.Description, entity.CreatedAt, entity.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteLabelCategoryAsync(string actorUserId, string categoryId)
    {
        var id = (categoryId ?? string.Empty).Trim();
        var entity = await dbContext.LabelCategories.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Label category not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var inUse = await dbContext.Labels.AsNoTracking().AnyAsync(x => x.CategoryId == id);
        if (inUse)
        {
            return ServiceResponse<bool>.Failure("Category is in use", ["Cannot delete category because labels are referencing it"]);
        }

        dbContext.LabelCategories.Remove(entity);
        await AddActivityLogAsync(actorUserId, "Manager.DeleteLabelCategory", "label_categories", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<AnnotationTypeResponse>> CreateAnnotationTypeAsync(string actorUserId, CreateAnnotationTypeRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == projectId);
        if (!projectExists)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.AnnotationTypeDefinitions.AsNoTracking().AnyAsync(x => x.ProjectId == projectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure("Annotation type already exists", ["Annotation type name already exists in project"]);
        }

        var entity = new AnnotationTypeDefinition
        {
            ProjectId = projectId,
            Name = name,
            Description = NormalizeOptionalText(request.Description)
        };

        dbContext.AnnotationTypeDefinitions.Add(entity);
        await AddActivityLogAsync(actorUserId, "Manager.CreateAnnotationType", "annotation_types", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<AnnotationTypeResponse>.Success(
            new AnnotationTypeResponse(entity.Id, entity.ProjectId, entity.Name, entity.Description, entity.CreatedAt, entity.UpdatedAt),
            "Created");
    }

    public async Task<ServiceResponse<List<AnnotationTypeResponse>>> GetAnnotationTypesAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<AnnotationTypeResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.AnnotationTypeDefinitions
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderBy(x => x.Name)
            .Select(x => new AnnotationTypeResponse(x.Id, x.ProjectId, x.Name, x.Description, x.CreatedAt, x.UpdatedAt))
            .ToListAsync();

        return ServiceResponse<List<AnnotationTypeResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<AnnotationTypeResponse>> UpdateAnnotationTypeAsync(string actorUserId, string annotationTypeId, UpdateAnnotationTypeRequest request)
    {
        var id = (annotationTypeId ?? string.Empty).Trim();
        var name = (request.Name ?? string.Empty).Trim();

        var entity = await dbContext.AnnotationTypeDefinitions.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure(ErrorMessages.NotFound, ["Annotation type not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure(access.Message, access.Errors);
        }

        var duplicate = await dbContext.AnnotationTypeDefinitions.AsNoTracking().AnyAsync(x => x.Id != id && x.ProjectId == entity.ProjectId && x.Name == name);
        if (duplicate)
        {
            return ServiceResponse<AnnotationTypeResponse>.Failure("Annotation type already exists", ["Annotation type name already exists in project"]);
        }

        entity.Name = name;
        entity.Description = NormalizeOptionalText(request.Description);

        await AddActivityLogAsync(actorUserId, "Manager.UpdateAnnotationType", "annotation_types", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<AnnotationTypeResponse>.Success(
            new AnnotationTypeResponse(entity.Id, entity.ProjectId, entity.Name, entity.Description, entity.CreatedAt, entity.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<bool>> DeleteAnnotationTypeAsync(string actorUserId, string annotationTypeId)
    {
        var id = (annotationTypeId ?? string.Empty).Trim();
        var entity = await dbContext.AnnotationTypeDefinitions.FirstOrDefaultAsync(x => x.Id == id);
        if (entity is null)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Annotation type not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, entity.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<bool>.Failure(access.Message, access.Errors);
        }

        var inUse = await dbContext.Labels.AsNoTracking().AnyAsync(x => x.AnnotationTypeId == id);
        if (inUse)
        {
            return ServiceResponse<bool>.Failure("Annotation type is in use", ["Cannot delete annotation type because labels are referencing it"]);
        }

        dbContext.AnnotationTypeDefinitions.Remove(entity);
        await AddActivityLogAsync(actorUserId, "Manager.DeleteAnnotationType", "annotation_types", entity.ProjectId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<bool>.Success(true, "Deleted");
    }

    public async Task<ServiceResponse<ProjectResponse>> UpdateProjectGuidelineAsync(string actorUserId, string projectId, UpdateProjectGuidelineRequest request)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<ProjectResponse>.Failure(access.Message, access.Errors);
        }

        var project = await dbContext.Projects.FirstOrDefaultAsync(x => x.Id == id);
        if (project is null)
        {
            return ServiceResponse<ProjectResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        project.Guideline = string.IsNullOrWhiteSpace(request.Guideline) ? null : request.Guideline.Trim();

        await AddActivityLogAsync(actorUserId, "Manager.UpdateGuideline", "projects", project.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<ProjectResponse>.Success(
            new ProjectResponse(project.Id, project.Name, project.Guideline, project.Status, project.CreatedAt, project.UpdatedAt),
            "Updated");
    }

    public async Task<ServiceResponse<TaskResponse>> CreateTaskAsync(string actorUserId, CreateTaskRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var dataItemId = (request.DataItemId ?? string.Empty).Trim();
        var annotatorId = (request.AnnotatorId ?? string.Empty).Trim();

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == projectId);
        if (!projectExists)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<TaskResponse>.Failure(access.Message, access.Errors);
        }

        var dataItem = await dbContext.DataItems.AsNoTracking().FirstOrDefaultAsync(x => x.Id == dataItemId);
        if (dataItem is null)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Data item not found"]);
        }

        if (!string.Equals(dataItem.Dataset?.ProjectId, projectId, StringComparison.Ordinal))
        {
            var dataItemProjectId = await dbContext.Datasets
                .AsNoTracking()
                .Where(x => x.Id == dataItem.DatasetId)
                .Select(x => x.ProjectId)
                .FirstOrDefaultAsync();

            if (!string.Equals(dataItemProjectId, projectId, StringComparison.Ordinal))
            {
                return ServiceResponse<TaskResponse>.Failure("Invalid data item", ["Data item does not belong to project"]);
            }
        }

        var annotator = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == annotatorId);
        if (annotator is null)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Annotator not found"]);
        }

        var entity = new LabelingTask
        {
            ProjectId = projectId,
            DataItemId = dataItemId,
            AnnotatorId = annotatorId,
            AssignedByUserId = actorUserId,
            AssignedAt = DateTime.UtcNow,
            Status = "Assigned"
        };

        dbContext.LabelingTasks.Add(entity);
        await dbContext.SaveChangesAsync();

        dbContext.TaskHistories.Add(new TaskHistory
        {
            TaskId = entity.Id,
            OldStatus = null,
            NewStatus = "Assigned",
            ChangedByUserId = actorUserId
        });

        await AddActivityLogAsync(actorUserId, "Manager.CreateTask", "tasks", entity.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<TaskResponse>.Success(ToTaskResponse(entity), "Created");
    }

    public async Task<ServiceResponse<int>> BulkCreateTasksByDatasetAsync(string actorUserId, BulkCreateTasksByDatasetRequest request)
    {
        var projectId = (request.ProjectId ?? string.Empty).Trim();
        var datasetId = (request.DatasetId ?? string.Empty).Trim();
        var annotatorId = (request.AnnotatorId ?? string.Empty).Trim();

        var projectExists = await dbContext.Projects.AsNoTracking().AnyAsync(x => x.Id == projectId);
        if (!projectExists)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<int>.Failure(access.Message, access.Errors);
        }

        var dataset = await dbContext.Datasets.AsNoTracking().FirstOrDefaultAsync(x => x.Id == datasetId);
        if (dataset is null)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.NotFound, ["Dataset not found"]);
        }

        if (!string.Equals(dataset.ProjectId, projectId, StringComparison.Ordinal))
        {
            return ServiceResponse<int>.Failure("Invalid dataset", ["Dataset does not belong to project"]);
        }

        var annotator = await dbContext.Users.AsNoTracking().FirstOrDefaultAsync(x => x.Id == annotatorId);
        if (annotator is null)
        {
            return ServiceResponse<int>.Failure(ErrorMessages.NotFound, ["Annotator not found"]);
        }

        // Find data items in the dataset that are NOT already assigned in this project
        var alreadyAssignedDataItemIds = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.ProjectId == projectId)
            .Select(x => x.DataItemId)
            .ToListAsync();

        var dataItemsToAssign = await dbContext.DataItems
            .AsNoTracking()
            .Where(x => x.DatasetId == datasetId && !alreadyAssignedDataItemIds.Contains(x.Id))
            .ToListAsync();

        if (dataItemsToAssign.Count == 0)
        {
            var totalItemsInDataset = await dbContext.DataItems.CountAsync(x => x.DatasetId == datasetId);
            if (totalItemsInDataset == 0)
            {
                return ServiceResponse<int>.Success(0, "The dataset is empty");
            }

            return ServiceResponse<int>.Success(0, "All items in this dataset are already assigned to tasks in this project");
        }

        var tasks = dataItemsToAssign.Select(item => new LabelingTask
        {
            ProjectId = projectId,
            DataItemId = item.Id,
            AnnotatorId = annotatorId,
            AssignedByUserId = actorUserId,
            AssignedAt = DateTime.UtcNow,
            Status = "Assigned"
        }).ToList();

        dbContext.LabelingTasks.AddRange(tasks);
        await dbContext.SaveChangesAsync();

        var histories = tasks.Select(task => new TaskHistory
        {
            TaskId = task.Id,
            OldStatus = null,
            NewStatus = "Assigned",
            ChangedByUserId = actorUserId
        }).ToList();

        dbContext.TaskHistories.AddRange(histories);
        await AddActivityLogAsync(actorUserId, "Manager.BulkCreateTasks", "datasets", datasetId);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<int>.Success(tasks.Count, $"{tasks.Count} tasks created");
    }

    public Task<ServiceResponse<TaskResponse>> AssignTaskAsync(string actorUserId, string taskId, AssignTaskRequest request)
        => ChangeTaskAssigneeAsync(actorUserId, taskId, request.AnnotatorId, "Manager.AssignTask");

    public async Task<ServiceResponse<int>> BulkAssignTasksAsync(string actorUserId, BulkAssignTasksRequest request)
    {
        var taskIds = request.TaskIds ?? [];
        if (taskIds.Count == 0)
        {
            return ServiceResponse<int>.Failure("Invalid request", ["TaskIds is required"]);
        }

        var success = 0;
        foreach (var taskId in taskIds)
        {
            var changed = await ChangeTaskAssigneeAsync(actorUserId, taskId, request.AnnotatorId, "Manager.BulkAssignTask");
            if (changed.IsSuccess)
            {
                success++;
            }
        }

        await dbContext.SaveChangesAsync();
        return ServiceResponse<int>.Success(success, "Updated");
    }

    public Task<ServiceResponse<TaskResponse>> ReassignTaskAsync(string actorUserId, string taskId, AssignTaskRequest request)
        => ChangeTaskAssigneeAsync(actorUserId, taskId, request.AnnotatorId, "Manager.ReassignTask");

    public Task<ServiceResponse<TaskResponse>> PauseTaskAsync(string actorUserId, string taskId)
        => ChangeTaskStatusAsync(actorUserId, taskId, "Paused", "Manager.PauseTask");

    public Task<ServiceResponse<TaskResponse>> ResumeTaskAsync(string actorUserId, string taskId)
        => ChangeTaskStatusAsync(actorUserId, taskId, "InProgress", "Manager.ResumeTask");

    public Task<ServiceResponse<TaskResponse>> CancelTaskAsync(string actorUserId, string taskId)
        => ChangeTaskStatusAsync(actorUserId, taskId, "Cancelled", "Manager.CancelTask");

    public Task<ServiceResponse<TaskResponse>> RequestRelabelingAsync(string actorUserId, string taskId, RequestRelabelingRequest request)
        => ChangeTaskStatusAsync(actorUserId, taskId, "Rework", "Manager.RequestRelabeling");

    public async Task<ServiceResponse<TaskProgressResponse>> GetTaskProgressAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<TaskProgressResponse>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<TaskProgressResponse>.Failure(access.Message, access.Errors);
        }

        var tasks = await dbContext.LabelingTasks.AsNoTracking().Where(x => x.ProjectId == id).Select(x => x.Status).ToListAsync();
        var response = new TaskProgressResponse(
            id,
            tasks.Count,
            tasks.Count(x => x == "Assigned"),
            tasks.Count(x => x == "InProgress"),
            tasks.Count(x => x == "Submitted"),
            tasks.Count(x => x == "Completed"),
            tasks.Count(x => x == "Paused"),
            tasks.Count(x => x == "Cancelled"),
            tasks.Count(x => x == "Rework"));

        return ServiceResponse<TaskProgressResponse>.Success(response, "OK");
    }

    public async Task<ServiceResponse<List<TaskResponse>>> GetProjectTasksAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<TaskResponse>>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<TaskResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .OrderByDescending(x => x.AssignedAt)
            .Select(x => new TaskResponse(
                x.Id,
                x.ProjectId,
                x.DataItemId,
                x.AnnotatorId,
                x.AssignedByUserId,
                x.Status,
                x.AssignedAt,
                x.CompletedAt,
                x.DataItem != null ? x.DataItem.ObjectKey : null,
                x.DataItem != null && x.DataItem.Dataset != null ? x.DataItem.Dataset.Name : null,
                x.Annotator != null ? x.Annotator.Email : null))
            .ToListAsync();

        return ServiceResponse<List<TaskResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<List<TaskHistoryResponse>>> GetTaskHistoryAsync(string actorUserId, string taskId)
    {
        var id = (taskId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<List<TaskHistoryResponse>>.Failure("Invalid task", ["Task id is required"]);
        }

        var projectId = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => x.ProjectId)
            .FirstOrDefaultAsync();

        if (string.IsNullOrWhiteSpace(projectId))
        {
            return ServiceResponse<List<TaskHistoryResponse>>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, projectId);
        if (access is not null)
        {
            return ServiceResponse<List<TaskHistoryResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.TaskHistories
            .AsNoTracking()
            .Where(x => x.TaskId == id)
            .OrderByDescending(x => x.ChangedAt)
            .Select(x => new TaskHistoryResponse(x.Id, x.TaskId, x.OldStatus, x.NewStatus, x.ChangedByUserId, x.ChangedAt))
            .ToListAsync();

        return ServiceResponse<List<TaskHistoryResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<LabelingProgressOverviewResponse>> GetLabelingProgressOverviewAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<LabelingProgressOverviewResponse>.Failure(access.Message, access.Errors);
        }

        var statuses = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .Select(x => x.Status)
            .ToListAsync();

        var total = statuses.Count;
        var completed = statuses.Count(x => string.Equals(x, "Completed", StringComparison.OrdinalIgnoreCase));
        var submitted = statuses.Count(x => string.Equals(x, "Submitted", StringComparison.OrdinalIgnoreCase));
        var active = statuses.Count(x => 
            string.Equals(x, "Assigned", StringComparison.OrdinalIgnoreCase) || 
            string.Equals(x, "InProgress", StringComparison.OrdinalIgnoreCase) || 
            string.Equals(x, "Paused", StringComparison.OrdinalIgnoreCase) || 
            string.Equals(x, "Rework", StringComparison.OrdinalIgnoreCase));

        var response = new LabelingProgressOverviewResponse(id, total, completed, submitted, active);
        return ServiceResponse<LabelingProgressOverviewResponse>.Success(response, "OK");
    }

    public async Task<ServiceResponse<List<AnnotatorPerformanceResponse>>> GetAnnotatorPerformanceAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<AnnotatorPerformanceResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.LabelingTasks
            .AsNoTracking()
            .Where(x => x.ProjectId == id)
            .GroupBy(x => new { x.AnnotatorId, Email = x.Annotator != null ? x.Annotator.Email : string.Empty })
            .Select(g => new AnnotatorPerformanceResponse(
                g.Key.AnnotatorId,
                g.Key.Email,
                g.Count(),
                g.Count(x => x.Status == "Submitted"),
                g.Count(x => x.Status == "Completed")))
            .ToListAsync();

        return ServiceResponse<List<AnnotatorPerformanceResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<ReviewStatisticsResponse>> GetReviewStatisticsAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<ReviewStatisticsResponse>.Failure(access.Message, access.Errors);
        }

        var reviews = await dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.AnnotationSet != null && r.AnnotationSet.Task != null && r.AnnotationSet.Task.ProjectId == id)
            .Select(r => new { r.Result, r.Score })
            .ToListAsync();

        var total = reviews.Count;
        var avg = total == 0 ? 0d : reviews.Average(x => (double)x.Score);

        var response = new ReviewStatisticsResponse(
            id,
            total,
            reviews.Count(x => string.Equals(x.Result, "Approved", StringComparison.OrdinalIgnoreCase)),
            reviews.Count(x => string.Equals(x.Result, "Rejected", StringComparison.OrdinalIgnoreCase)),
            avg);

        return ServiceResponse<ReviewStatisticsResponse>.Success(response, "OK");
    }

    public async Task<ServiceResponse<List<InconsistentLabelResponse>>> DetectInconsistentLabelsAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<List<InconsistentLabelResponse>>.Failure(access.Message, access.Errors);
        }

        var items = await dbContext.Annotations
            .AsNoTracking()
            .Where(a => a.AnnotationSet != null && a.AnnotationSet.Task != null && a.AnnotationSet.Task.ProjectId == id)
            .Where(a => string.IsNullOrWhiteSpace(a.GeometryData) || a.AnnotationType != "bbox")
            .Select(a => new InconsistentLabelResponse(
                a.Id,
                a.AnnotationSet!.TaskId,
                a.LabelId,
                string.IsNullOrWhiteSpace(a.GeometryData) ? "Missing geometry" : "Unsupported annotation type"))
            .Take(500)
            .ToListAsync();

        return ServiceResponse<List<InconsistentLabelResponse>>.Success(items, "OK");
    }

    public async Task<ServiceResponse<QualityReportResponse>> ExportQualityReportAsync(string actorUserId, string projectId)
    {
        var progress = await GetLabelingProgressOverviewAsync(actorUserId, projectId);
        if (!progress.IsSuccess || progress.Data is null)
        {
            return ServiceResponse<QualityReportResponse>.Failure(progress.Message, progress.Errors);
        }

        var reviewStats = await GetReviewStatisticsAsync(actorUserId, projectId);
        if (!reviewStats.IsSuccess || reviewStats.Data is null)
        {
            return ServiceResponse<QualityReportResponse>.Failure(reviewStats.Message, reviewStats.Errors);
        }

        var inconsistent = await DetectInconsistentLabelsAsync(actorUserId, projectId);
        if (!inconsistent.IsSuccess || inconsistent.Data is null)
        {
            return ServiceResponse<QualityReportResponse>.Failure(inconsistent.Message, inconsistent.Errors);
        }

        return ServiceResponse<QualityReportResponse>.Success(
            new QualityReportResponse(progress.Data, reviewStats.Data, inconsistent.Data.Count),
            "OK");
    }

    public async Task<ServiceResponse<ExportValidationResponse>> ValidateApprovedDataAsync(string actorUserId, string projectId)
    {
        var id = (projectId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<ExportValidationResponse>.Failure("Invalid project", ["Project id is required"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, id);
        if (access is not null)
        {
            return ServiceResponse<ExportValidationResponse>.Failure(access.Message, access.Errors);
        }

        var submitted = await dbContext.AnnotationSets
            .AsNoTracking()
            .CountAsync(x => x.Status == "Submitted" && dbContext.LabelingTasks.Any(t => t.Id == x.TaskId && t.ProjectId == id));

        var reviewed = await dbContext.Reviews
            .AsNoTracking()
            .CountAsync(r => dbContext.AnnotationSets.Any(s => s.Id == r.AnnotationSetId && dbContext.LabelingTasks.Any(t => t.Id == s.TaskId && t.ProjectId == id)));

        var response = new ExportValidationResponse(id, submitted, reviewed, submitted > 0 && reviewed >= submitted);
        return ServiceResponse<ExportValidationResponse>.Success(response, "OK");
    }

    public async Task<ServiceResponse<ExportDownloadInfoResponse>> GetExportDownloadInfoAsync(string actorUserId, string exportId)
    {
        var id = (exportId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(id))
        {
            return ServiceResponse<ExportDownloadInfoResponse>.Failure("Invalid export", ["Export id is required"]);
        }

        var item = await dbContext.Exports
            .AsNoTracking()
            .Where(x => x.Id == id)
            .Select(x => new { x.Id, x.ProjectId, x.ExportPath, x.Format })
            .FirstOrDefaultAsync();

        if (item is null)
        {
            return ServiceResponse<ExportDownloadInfoResponse>.Failure(ErrorMessages.NotFound, ["Export not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, item.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<ExportDownloadInfoResponse>.Failure(access.Message, access.Errors);
        }

        var fileName = Path.GetFileName(item.ExportPath);
        if (string.IsNullOrWhiteSpace(fileName))
        {
            var ext = string.Equals(item.Format, "YOLO", StringComparison.OrdinalIgnoreCase) ? ".zip" : ".json";
            fileName = $"export-{item.Id}{ext}";
        }
        else if (string.Equals(item.Format, "YOLO", StringComparison.OrdinalIgnoreCase) && !fileName.EndsWith(".zip", StringComparison.OrdinalIgnoreCase))
        {
            // Fix extension for old records or mismatched paths
            fileName = Path.ChangeExtension(fileName, ".zip");
        }

        return ServiceResponse<ExportDownloadInfoResponse>.Success(
            new ExportDownloadInfoResponse(item.Id, "Local", item.ExportPath, fileName),
            "OK");
    }

    private async Task<ServiceResponse<TaskResponse>> ChangeTaskAssigneeAsync(string actorUserId, string taskId, string annotatorId, string action)
    {
        var id = (taskId ?? string.Empty).Trim();
        var newAnnotatorId = (annotatorId ?? string.Empty).Trim();

        var task = await dbContext.LabelingTasks.FirstOrDefaultAsync(x => x.Id == id);
        if (task is null)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, task.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<TaskResponse>.Failure(access.Message, access.Errors);
        }

        var annotatorExists = await dbContext.Users.AsNoTracking().AnyAsync(x => x.Id == newAnnotatorId);
        if (!annotatorExists)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Annotator not found"]);
        }

        var oldStatus = task.Status;
        task.AnnotatorId = newAnnotatorId;
        task.AssignedByUserId = actorUserId;
        task.AssignedAt = DateTime.UtcNow;
        task.Status = "Assigned";

        dbContext.TaskHistories.Add(new TaskHistory
        {
            TaskId = task.Id,
            OldStatus = oldStatus,
            NewStatus = task.Status,
            ChangedByUserId = actorUserId
        });

        await AddActivityLogAsync(actorUserId, action, "tasks", task.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<TaskResponse>.Success(ToTaskResponse(task), "Updated");
    }

    private async Task<ServiceResponse<TaskResponse>> ChangeTaskStatusAsync(string actorUserId, string taskId, string newStatus, string action)
    {
        var id = (taskId ?? string.Empty).Trim();
        var task = await dbContext.LabelingTasks.FirstOrDefaultAsync(x => x.Id == id);
        if (task is null)
        {
            return ServiceResponse<TaskResponse>.Failure(ErrorMessages.NotFound, ["Task not found"]);
        }

        var access = await EnsureProjectAccessAsync(actorUserId, task.ProjectId);
        if (access is not null)
        {
            return ServiceResponse<TaskResponse>.Failure(access.Message, access.Errors);
        }

        var oldStatus = task.Status;
        task.Status = newStatus;
        if (string.Equals(newStatus, "Completed", StringComparison.OrdinalIgnoreCase))
        {
            task.CompletedAt = DateTime.UtcNow;
        }

        dbContext.TaskHistories.Add(new TaskHistory
        {
            TaskId = task.Id,
            OldStatus = oldStatus,
            NewStatus = newStatus,
            ChangedByUserId = actorUserId
        });

        await AddActivityLogAsync(actorUserId, action, "tasks", task.Id);
        await dbContext.SaveChangesAsync();

        return ServiceResponse<TaskResponse>.Success(ToTaskResponse(task), "Updated");
    }

    private static TaskResponse ToTaskResponse(LabelingTask task)
        => new(
            task.Id,
            task.ProjectId,
            task.DataItemId,
            task.AnnotatorId,
            task.AssignedByUserId,
            task.Status,
            task.AssignedAt,
            task.CompletedAt,
            task.DataItem?.ObjectKey,
            task.DataItem?.Dataset?.Name,
            task.Annotator?.Email);

    private static string? NormalizeOptionalId(string? value)
    {
        var normalized = (value ?? string.Empty).Trim();
        return string.IsNullOrWhiteSpace(normalized) ? null : normalized;
    }

    private static string? NormalizeOptionalText(string? value)
    {
        var normalized = (value ?? string.Empty).Trim();
        return string.IsNullOrWhiteSpace(normalized) ? null : normalized;
    }

    private string BuildExportObjectKey(string projectId, string exportId, string requestedPath)
    {
        var normalized = (requestedPath ?? string.Empty).Trim().Replace('\\', '/');
        if (!string.IsNullOrWhiteSpace(normalized))
        {
            return normalized.TrimStart('/');
        }

        return $"exports/{projectId}/export-{exportId}.json";
    }

    private async Task<string> BuildApprovedExportJsonAsync(string projectId, string includeFieldsJson, string filtersJson)
    {
        HashSet<string> includeFields;
        try
        {
            includeFields = JsonSerializer.Deserialize<HashSet<string>>(includeFieldsJson) ?? [];
        }
        catch
        {
            includeFields = [];
        }

        if (includeFields.Count == 0)
        {
            includeFields = ["tasks", "annotations", "reviews", "labels"];
        }

        var approvedAnnotationSetIds = await dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.Result == "Approved" && r.AnnotationSet!.Task!.ProjectId == projectId)
            .Select(r => r.AnnotationSetId)
            .Distinct()
            .ToListAsync();

        var payload = new Dictionary<string, object?>
        {
            ["projectId"] = projectId,
            ["generatedAt"] = DateTime.UtcNow
        };

        try
        {
            payload["filters"] = JsonSerializer.Deserialize<object>(filtersJson);
        }
        catch
        {
            payload["filters"] = new Dictionary<string, string>();
        }

        if (includeFields.Contains("labels", StringComparer.OrdinalIgnoreCase))
        {
            payload["labels"] = await dbContext.Labels.AsNoTracking()
                .Where(x => x.ProjectId == projectId)
                .Select(x => new { x.Id, x.Name, x.YoloClassId, x.CategoryId, x.AnnotationTypeId })
                .ToListAsync();
        }

        if (includeFields.Contains("tasks", StringComparer.OrdinalIgnoreCase))
        {
            payload["tasks"] = await dbContext.LabelingTasks.AsNoTracking()
                .Where(x => x.ProjectId == projectId)
                .Select(x => new { x.Id, x.DataItemId, x.AnnotatorId, x.Status, x.AssignedAt, x.CompletedAt })
                .ToListAsync();
        }

        if (includeFields.Contains("reviews", StringComparer.OrdinalIgnoreCase))
        {
            payload["reviews"] = await dbContext.Reviews.AsNoTracking()
                .Where(r => approvedAnnotationSetIds.Contains(r.AnnotationSetId))
                .Select(r => new { r.Id, r.AnnotationSetId, r.ReviewerId, r.Result, r.Score, r.Comment, r.ReviewedAt })
                .ToListAsync();
        }

        if (includeFields.Contains("annotations", StringComparer.OrdinalIgnoreCase))
        {
            payload["annotations"] = await dbContext.Annotations.AsNoTracking()
                .Where(a => approvedAnnotationSetIds.Contains(a.AnnotationSetId))
                .Select(a => new { a.Id, a.AnnotationSetId, a.LabelId, a.AnnotationType, a.GeometryData, a.Version, a.CreatedAt, a.UpdatedAt })
                .ToListAsync();
        }

        return JsonSerializer.Serialize(payload, new JsonSerializerOptions { WriteIndented = true });
    }

    private async Task<byte[]> BuildApprovedExportYoloZipAsync(string projectId)
    {
        var approvedAnnotationSetIds = await dbContext.Reviews
            .AsNoTracking()
            .Where(r => r.Result == "Approved")
            .Join(dbContext.AnnotationSets.Where(s => s.Task!.ProjectId == projectId),
                  r => r.AnnotationSetId,
                  s => s.Id,
                  (r, s) => r.AnnotationSetId)
            .Distinct()
            .ToListAsync();

        logger.LogInformation("Found {Count} approved annotation sets for project {ProjectId}", approvedAnnotationSetIds.Count, projectId);

        var labels = await dbContext.Labels.AsNoTracking()
            .Where(x => x.ProjectId == projectId)
            .OrderBy(x => x.YoloClassId)
            .Select(x => new { x.Id, x.Name, x.YoloClassId })
            .ToListAsync();

        var tasks = await dbContext.LabelingTasks.AsNoTracking()
            .Include(t => t.DataItem)
            .Where(t => t.ProjectId == projectId && (t.Status == "Completed" || t.Status == "Submitted"))
            .ToListAsync();

        logger.LogInformation("Processing {Count} tasks for YOLO export", tasks.Count);

        using var memoryStream = new MemoryStream();
        using (var archive = new ZipArchive(memoryStream, ZipArchiveMode.Create, true))
        {
            // 1. Create classes.txt
            var classesEntry = archive.CreateEntry("classes.txt");
            using (var writer = new StreamWriter(classesEntry.Open()))
            {
                foreach (var label in labels)
                {
                    await writer.WriteLineAsync(label.Name);
                }
            }

            // 2. Create labels for each task
            int filesWritten = 0;
            foreach (var task in tasks)
            {
                var annotations = await dbContext.Annotations.AsNoTracking()
                    .Where(a => a.AnnotationSet!.TaskId == task.Id && approvedAnnotationSetIds.Contains(a.AnnotationSetId))
                    .ToListAsync();

                if (annotations.Count == 0) continue;

                var fileName = Path.GetFileNameWithoutExtension(task.DataItem?.ObjectKey ?? task.Id);
                var labelEntry = archive.CreateEntry($"labels/{fileName}.txt");

                using var writer = new StreamWriter(labelEntry.Open());
                foreach (var ann in annotations)
                {
                    try
                    {
                        var geo = JsonSerializer.Deserialize<JsonElement>(ann.GeometryData);
                        if (geo.ValueKind == JsonValueKind.Object)
                        {
                            var label = labels.FirstOrDefault(l => l.Id == ann.LabelId);
                            if (label == null) continue;

                            double x = geo.TryGetProperty("x", out var xProp) ? xProp.GetDouble() : 0;
                            double y = geo.TryGetProperty("y", out var yProp) ? yProp.GetDouble() : 0;
                            double w = geo.TryGetProperty("width", out var wProp) ? wProp.GetDouble() : 0;
                            double h = geo.TryGetProperty("height", out var hProp) ? hProp.GetDouble() : 0;

                            double imgW = task.DataItem?.OriginalWidth > 0 ? task.DataItem.OriginalWidth : 800.0;
                            double imgH = task.DataItem?.OriginalHeight > 0 ? task.DataItem.OriginalHeight : 600.0;

                            // YOLO format: <class_id> <x_center> <y_center> <width> <height> (normalized 0-1)
                            double xCenter = (x + (w / 2.0)) / imgW;
                            double yCenter = (y + (h / 2.0)) / imgH;
                            double wNorm = w / imgW;
                            double hNorm = h / imgH;

                            await writer.WriteLineAsync($"{label.YoloClassId} {xCenter:F6} {yCenter:F6} {wNorm:F6} {hNorm:F6}");
                        }
                    }
                    catch (Exception ex)
                    {
                        logger.LogWarning("Failed to parse geometry for annotation {Id}: {Message}", ann.Id, ex.Message);
                    }
                }
                filesWritten++;
            }
            logger.LogInformation("Successfully wrote {Count} label files to ZIP", filesWritten);
        }

        return memoryStream.ToArray();
    }

    private async Task<bool> WriteExportFileAsync(string objectKey, byte[] content)
    {
        try
        {
            var root = storageOptions.Value.LocalRootPath;
            if (string.IsNullOrWhiteSpace(root))
            {
                root = "storage";
            }

            var rootPath = Path.IsPathRooted(root)
                ? root
                : Path.Combine(hostEnvironment.ContentRootPath, root);

            var normalizedKey = objectKey.Replace('\\', '/').TrimStart('/');
            var fullPath = Path.GetFullPath(Path.Combine(rootPath, normalizedKey));
            var normalizedRoot = Path.GetFullPath(rootPath);

            if (!fullPath.StartsWith(normalizedRoot, StringComparison.OrdinalIgnoreCase))
            {
                return false;
            }

            var dir = Path.GetDirectoryName(fullPath);
            if (!string.IsNullOrWhiteSpace(dir))
            {
                Directory.CreateDirectory(dir);
            }

            await File.WriteAllBytesAsync(fullPath, content);
            return true;
        }
        catch
        {
            return false;
        }
    }

    private async Task<bool> IsSystemAdminAsync(string actorUserId)
    {
        var normalizedActorUserId = (actorUserId ?? string.Empty).Trim();
        if (string.IsNullOrWhiteSpace(normalizedActorUserId))
        {
            return false;
        }

        var roleName = await dbContext.Users
            .AsNoTracking()
            .Where(x => x.Id == normalizedActorUserId)
            .Select(x => x.Role != null ? x.Role.Name : string.Empty)
            .FirstOrDefaultAsync();

        return string.Equals(roleName, "Admin", StringComparison.OrdinalIgnoreCase);
    }

    private async Task<ServiceResponse<bool>?> EnsureProjectAccessAsync(string actorUserId, string projectId)
    {
        var normalizedActorUserId = (actorUserId ?? string.Empty).Trim();
        var normalizedProjectId = (projectId ?? string.Empty).Trim();

        if (string.IsNullOrWhiteSpace(normalizedActorUserId))
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.Unauthorized, ["Missing actor user id"]);
        }

        if (string.IsNullOrWhiteSpace(normalizedProjectId))
        {
            return ServiceResponse<bool>.Failure("Invalid project", ["Project id is required"]);
        }

        var projectExists = await dbContext.Projects
            .AsNoTracking()
            .AnyAsync(x => x.Id == normalizedProjectId);

        if (!projectExists)
        {
            return ServiceResponse<bool>.Failure(ErrorMessages.NotFound, ["Project not found"]);
        }

        if (await IsSystemAdminAsync(normalizedActorUserId))
        {
            return null;
        }

        var hasMembership = await dbContext.UserProjectRoles
            .AsNoTracking()
            .AnyAsync(x => x.UserId == normalizedActorUserId && x.ProjectId == normalizedProjectId);

        if (hasMembership)
        {
            return null;
        }

        return ServiceResponse<bool>.Failure(ErrorMessages.Forbidden, ["You do not have access to this project"]);
    }

    private async Task AddActivityLogAsync(string userId, string action, string targetType, string targetId)
    {
        var normalizedUserId = (userId ?? string.Empty).Trim();

        var userExists = !string.IsNullOrWhiteSpace(normalizedUserId)
            && await dbContext.Users.AsNoTracking().AnyAsync(x => x.Id == normalizedUserId);

        if (!userExists)
        {
            return;
        }

        dbContext.ActivityLogs.Add(new ActivityLog
        {
            UserId = normalizedUserId,
            Action = action,
            TargetType = targetType,
            TargetId = string.IsNullOrWhiteSpace(targetId)
                ? "unknown"
                : targetId.Trim()[..Math.Min(24, targetId.Trim().Length)]
        });
    }
}
