using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class UserProjectRole
{
    [Required]
    [MaxLength(24)]
    public string UserId { get; set; } = string.Empty;

    [ForeignKey(nameof(UserId))]
    public User? User { get; set; }

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    [ForeignKey(nameof(ProjectId))]
    public Project? Project { get; set; }

    [Required]
    [MaxLength(24)]
    public string RoleId { get; set; } = string.Empty;

    [ForeignKey(nameof(RoleId))]
    public Role? Role { get; set; }
}
