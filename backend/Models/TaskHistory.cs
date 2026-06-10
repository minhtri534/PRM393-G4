using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class TaskHistory
{
    [Key]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty; // history_id

    [Required]
    [MaxLength(24)]
    public string TaskId { get; set; } = string.Empty;

    [ForeignKey(nameof(TaskId))]
    public LabelingTask? Task { get; set; }

    public string? OldStatus { get; set; }

    public string? NewStatus { get; set; }

    [MaxLength(24)]
    public string ChangedByUserId { get; set; } = string.Empty;

    [ForeignKey(nameof(ChangedByUserId))]
    public User? ChangedByUser { get; set; }

    public DateTime ChangedAt { get; set; }
}
