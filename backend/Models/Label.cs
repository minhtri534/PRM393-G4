using System.ComponentModel.DataAnnotations;

namespace DataLabellingSupportSystem.Api.Models;

public class Label
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    public Project? Project { get; set; }

    [Required]
    [MaxLength(100)]
    public string Name { get; set; } = string.Empty;

    [MaxLength(24)]
    public string? CategoryId { get; set; }

    public LabelCategory? Category { get; set; }

    [MaxLength(24)]
    public string? AnnotationTypeId { get; set; }

    public AnnotationTypeDefinition? AnnotationType { get; set; }

    public int YoloClassId { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
