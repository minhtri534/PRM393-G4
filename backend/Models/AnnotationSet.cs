using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class AnnotationSet
{
    [Key]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string TaskId { get; set; } = string.Empty;

    [ForeignKey(nameof(TaskId))]
    public LabelingTask? Task { get; set; }

    [Required]
    [MaxLength(24)]
    public string CreatedByUserId { get; set; } = string.Empty;

    [ForeignKey(nameof(CreatedByUserId))]
    public User? CreatedByUser { get; set; }

    [Required]
    public string Status { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    // Navigation property
    public ICollection<Annotation> Annotations { get; set; } = new List<Annotation>();
}
