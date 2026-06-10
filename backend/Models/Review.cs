using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class Review
{
    [Key]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty; // review_id

    [Required]
    [MaxLength(24)]
    public string AnnotationSetId { get; set; } = string.Empty;

    [ForeignKey(nameof(AnnotationSetId))]
    public AnnotationSet? AnnotationSet { get; set; }

    [Required]
    [MaxLength(24)]
    public string ReviewerId { get; set; } = string.Empty;

    [ForeignKey(nameof(ReviewerId))]
    public User? Reviewer { get; set; }

    [Required]
    public string Result { get; set; } = string.Empty;

    public int Score { get; set; }

    public string? Comment { get; set; }

    public DateTime ReviewedAt { get; set; }

    // Navigation for errors
    public ICollection<ReviewError> ReviewErrors { get; set; } = new List<ReviewError>();
}
