namespace DataLabellingSupportSystem.Api.DTOs.Responses.Annotator;

public sealed record AnnotatorReviewFeedbackResponse(
    string ReviewId,
    string AnnotationSetId,
    string Result,
    int Score,
    string? Comment,
    DateTime ReviewedAt,
    List<AnnotatorReviewErrorCategoryResponse> ErrorCategories
);

public sealed record AnnotatorReviewErrorCategoryResponse(
    string ErrorTypeId,
    string ErrorName,
    string? Description
);
