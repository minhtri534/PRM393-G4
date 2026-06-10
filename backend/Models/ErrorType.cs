using System.ComponentModel.DataAnnotations;

namespace DataLabellingSupportSystem.Api.Models;

public class ErrorType
{
    [Key]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty; // error_type_id

    [Required]
    public string ErrorName { get; set; } = string.Empty;

    public string? Description { get; set; }
}
