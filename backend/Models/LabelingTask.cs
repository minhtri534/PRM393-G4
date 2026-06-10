using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class LabelingTask
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    public Project? Project { get; set; }

    [Required]
    [MaxLength(24)]
    public string DataItemId { get; set; } = string.Empty;

    [ForeignKey(nameof(DataItemId))]
    public DataItem? DataItem { get; set; }

    [Required]
    [MaxLength(24)]
    public string AnnotatorId { get; set; } = string.Empty;

    [ForeignKey(nameof(AnnotatorId))]
    public User? Annotator { get; set; }

    [MaxLength(24)]
    public string? AssignedByUserId { get; set; }

    [ForeignKey(nameof(AssignedByUserId))]
    public User? AssignedByUser { get; set; }

    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = "Assigned";

    public DateTime? AssignedAt { get; set; }

    public DateTime? CompletedAt { get; set; }
}
