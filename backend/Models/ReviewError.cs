using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Models;

[PrimaryKey(nameof(ReviewId), nameof(ErrorTypeId))]
public class ReviewError
{
    [MaxLength(24)]
    [ForeignKey(nameof(ReviewId))]
    public string ReviewId { get; set; } = string.Empty;

    [MaxLength(24)]
    public string ErrorTypeId { get; set; } = string.Empty;

    [ForeignKey(nameof(ErrorTypeId))]
    public ErrorType? ErrorType { get; set; }
}
