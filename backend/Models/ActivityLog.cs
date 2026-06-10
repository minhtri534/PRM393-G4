using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class ActivityLog
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string UserId { get; set; } = string.Empty;

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    [Required]
    [MaxLength(120)]
    public string Action { get; set; } = string.Empty;

    [Required]
    [MaxLength(50)]
    public string TargetType { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string TargetId { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
}
