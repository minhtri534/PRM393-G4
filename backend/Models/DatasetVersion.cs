using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class DatasetVersion
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string DatasetId { get; set; } = string.Empty;

    [ForeignKey(nameof(DatasetId))]
    public Dataset? Dataset { get; set; }

    [Required]
    [MaxLength(150)]
    public string VersionName { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; }
}
