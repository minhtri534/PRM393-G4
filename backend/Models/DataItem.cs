using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class DataItem
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string DatasetId { get; set; } = string.Empty;

    public Dataset? Dataset { get; set; }

    [Required]
    [MaxLength(20)]
    public string StorageProvider { get; set; } = "Local";

    [Required]
    [MaxLength(500)]
    public string ObjectKey { get; set; } = string.Empty;

    public int OriginalWidth { get; set; }

    public int OriginalHeight { get; set; }

    [MaxLength(50)]
    public string DataType { get; set; } = "Image";

    [MaxLength(64)]
    public string? Checksum { get; set; }

    [MaxLength(20)]
    public string Status { get; set; } = "Active";

    [MaxLength(24)]
    public string? UploadedByUserId { get; set; }

    [ForeignKey(nameof(UploadedByUserId))]
    public User? UploadedByUser { get; set; }

    public DateTime CreatedAt { get; set; }

    public DateTime UpdatedAt { get; set; }
}
