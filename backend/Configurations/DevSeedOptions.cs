namespace DataLabellingSupportSystem.Api.Configurations;

public sealed class DevSeedOptions
{
    public bool Enabled { get; init; } = true;

    public string AnnotatorEmail { get; init; } = "annotator@demo.local";

    public string AnnotatorPassword { get; init; } = "Password123!";

    public string AnnotatorFullName { get; init; } = "Demo Annotator";

    public string AdminEmail { get; init; } = "admin@demo.local";

    public string AdminPassword { get; init; } = "Password123!";

    public string AdminFullName { get; init; } = "System Administrator";

    public string ManagerEmail { get; init; } = "manager@demo.local";

    public string ManagerPassword { get; init; } = "Password123!";

    public string ManagerFullName { get; init; } = "Demo Manager";

    public string ReviewerEmail { get; init; } = "reviewer@demo.local";

    public string ReviewerPassword { get; init; } = "Password123!";

    public string ReviewerFullName { get; init; } = "Demo Reviewer";

    public string ProjectName { get; init; } = "Demo Project";

    public string DatasetName { get; init; } = "Demo Dataset";
}
