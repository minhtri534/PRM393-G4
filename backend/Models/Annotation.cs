using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class Annotation
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string AnnotationSetId { get; set; } = string.Empty;

    [ForeignKey(nameof(AnnotationSetId))]
    public AnnotationSet? AnnotationSet { get; set; }

    [Required]
    [MaxLength(24)]
    public string LabelId { get; set; } = string.Empty;

    public Label? Label { get; set; }

    [Required]
    [MaxLength(50)]
    public string AnnotationType { get; set; } = "bbox";

    [Required]
    public string GeometryData { get; set; } = string.Empty;

    public int Version { get; set; } = 1;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
