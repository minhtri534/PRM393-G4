using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace DataLabellingSupportSystem.Api.Models;

public class ProjectChatMessage
{
    [Required]
    [MaxLength(24)]
    public string Id { get; set; } = string.Empty;

    [Required]
    [MaxLength(24)]
    public string ProjectId { get; set; } = string.Empty;

    [ForeignKey(nameof(ProjectId))]
    public Project? Project { get; set; }

    [Required]
    [MaxLength(24)]
    public string SenderUserId { get; set; } = string.Empty;

    [ForeignKey(nameof(SenderUserId))]
    public User? SenderUser { get; set; }

    [Required]
    [MaxLength(20)]
    public string MessageType { get; set; } = "text";

    [MaxLength(2000)]
    public string? Content { get; set; }

    [MaxLength(500)]
    public string? AttachmentObjectKey { get; set; }

    [MaxLength(255)]
    public string? AttachmentFileName { get; set; }

    [MaxLength(120)]
    public string? AttachmentContentType { get; set; }

    public long? AttachmentSizeBytes { get; set; }

    public DateTime CreatedAt { get; set; }
}
