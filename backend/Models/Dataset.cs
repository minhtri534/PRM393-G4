using System.ComponentModel.DataAnnotations;

namespace DataLabellingSupportSystem.Api.Models;

public class Dataset
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    public Project? Project { get; set; }

    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
