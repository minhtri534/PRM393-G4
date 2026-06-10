using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class Export
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    [ForeignKey(nameof(ProjectId))]
    public Project? Project { get; set; }

    [Required]
    [MaxLength(50)]
    public string Format { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ExportedByUserId { get; set; } = string.Empty;

    [ForeignKey(nameof(ExportedByUserId))]
    public User? ExportedByUser { get; set; }

    [Required]
    [MaxLength(500)]
    public string ExportPath { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public ExportConfig? ExportConfig { get; set; }
}
