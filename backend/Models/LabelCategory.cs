using System.ComponentModel.DataAnnotations;

namespace DataLabellingSupportSystem.Api.Models;

public class LabelCategory
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

    [MaxLength(500)]
    public string? Description { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
