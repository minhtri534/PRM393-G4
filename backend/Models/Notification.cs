using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class Notification
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string RecipientUserId { get; set; } = string.Empty;

    [ForeignKey(nameof(RecipientUserId))]
    public User? RecipientUser { get; set; }

    [MaxLength(24)]
    public string? ActorUserId { get; set; }

    [ForeignKey(nameof(ActorUserId))]
    public User? ActorUser { get; set; }

    [MaxLength(24)]
    public string? ProjectId { get; set; }

    [ForeignKey(nameof(ProjectId))]
    public Project? Project { get; set; }

    /// <summary>chat_message | project_announce | project_assigned</summary>
    [Required]
    [MaxLength(40)]
    public string Type { get; set; } = string.Empty;

    [Required]
    [MaxLength(200)]
    public string Title { get; set; } = string.Empty;

    [MaxLength(1000)]
    public string? Body { get; set; }

    [MaxLength(24)]
    public string? RelatedEntityId { get; set; }

    public bool IsRead { get; set; }

    public DateTime CreatedAt { get; set; }
}
