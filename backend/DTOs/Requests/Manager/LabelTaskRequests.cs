namespace DataLabellingSupportSystem.Api.DTOs.Requests.Manager;

public sealed record CreateLabelRequest(
    string ProjectId,
    string Name,
    int YoloClassId,
    string? CategoryId = null,
    string? AnnotationTypeId = null
);

public sealed record UpdateLabelRequest(
    string Name,
    int YoloClassId,
    string? CategoryId = null,
    string? AnnotationTypeId = null
);

public sealed record CreateLabelCategoryRequest(
    string ProjectId,
    string Name,
    string? Description
);

public sealed record UpdateLabelCategoryRequest(
    string Name,
    string? Description
);

public sealed record CreateAnnotationTypeRequest(
    string ProjectId,
    string Name,
    string? Description
);

public sealed record UpdateAnnotationTypeRequest(
    string Name,
    string? Description
);

public sealed record CreateTaskRequest(
    string ProjectId,
    string DataItemId,
    string AnnotatorId
);

public sealed record BulkCreateTasksByDatasetRequest(
    string ProjectId,
    string DatasetId,
    string AnnotatorId
);

public sealed record AssignTaskRequest(
    string AnnotatorId
);

public sealed record BulkAssignTasksRequest(
    List<string> TaskIds,
    string AnnotatorId
);

public sealed record RequestRelabelingRequest(
    string Reason
);

public sealed record UpdateProjectGuidelineRequest(
    string? Guideline
);
