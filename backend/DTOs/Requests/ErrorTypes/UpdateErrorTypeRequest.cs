namespace DataLabellingSupportSystem.Api.DTOs.Requests.Reviews;

public sealed record UpdateErrorTypeRequest(
     string ErrorName,
    string? Description
);
