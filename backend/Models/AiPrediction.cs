using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class AiPrediction
{
    [Key]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty; // prediction_id

    [Required]
    [MaxLength(24)]
    public string DataItemId { get; set; } = string.Empty;

    [MaxLength(24)]
    public string? TaskId { get; set; }

    [ForeignKey(nameof(DataItemId))]
    public DataItem? DataItem { get; set; }

    [Required]
    public string ModelName { get; set; } = string.Empty;

    [Required]
    public string PredictionData { get; set; } = string.Empty; // JSON

    public float Confidence { get; set; }

    [Required]
    [MaxLength(20)]
    public string Decision { get; set; } = "Pending";

    public bool IsAccepted { get; set; }

    [MaxLength(24)]
    public string? AppliedAnnotationSetId { get; set; }

    [MaxLength(24)]
    public string? AcceptedByUserId { get; set; }

    [ForeignKey(nameof(AcceptedByUserId))]
    public User? AcceptedByUser { get; set; }

    public DateTime? AcceptedAt { get; set; }

    public DateTime CreatedAt { get; set; }
}
