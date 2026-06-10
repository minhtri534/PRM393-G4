using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class ExportConfig
{
    [Required]
    [MaxLength(24)]
    public string ExportId { get; set; } = string.Empty;

    [ForeignKey(nameof(ExportId))]
    public Export? Export { get; set; }

    [Required]
    [MaxLength(100)]
    public string LabelFormat { get; set; } = string.Empty;

    [Required]
    public string IncludeFields { get; set; } = "[]";

    [Required]
    public string Filters { get; set; } = "{}";
}
