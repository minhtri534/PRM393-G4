using System.ComponentModel.DataAnnotations;

namespace DataLabellingSupportSystem.Api.Models;

public class Project
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string Name { get; set; } = string.Empty;

    public string? Guideline { get; set; }

    public int Status { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
