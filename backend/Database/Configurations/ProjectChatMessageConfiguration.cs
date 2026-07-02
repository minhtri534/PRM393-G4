using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class ProjectChatMessageConfiguration : IEntityTypeConfiguration<ProjectChatMessage>
{
    public void Configure(EntityTypeBuilder<ProjectChatMessage> builder)
    {
        builder.ToTable("project_chat_messages");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("message_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.ProjectId)
            .HasColumnName("project_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.SenderUserId)
            .HasColumnName("sender_user_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.MessageType)
            .HasColumnName("message_type")
            .HasColumnType("varchar(20)")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(x => x.Content)
            .HasColumnName("content")
            .HasColumnType("nvarchar(2000)")
            .HasMaxLength(2000);

        builder.Property(x => x.AttachmentObjectKey)
            .HasColumnName("attachment_object_key")
            .HasColumnType("varchar(500)")
            .HasMaxLength(500);

        builder.Property(x => x.AttachmentFileName)
            .HasColumnName("attachment_file_name")
            .HasColumnType("nvarchar(255)")
            .HasMaxLength(255);

        builder.Property(x => x.AttachmentContentType)
            .HasColumnName("attachment_content_type")
            .HasColumnType("varchar(120)")
            .HasMaxLength(120);

        builder.Property(x => x.AttachmentSizeBytes)
            .HasColumnName("attachment_size_bytes");

        builder.Property(x => x.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.SenderUser)
            .WithMany()
            .HasForeignKey(x => x.SenderUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(x => new { x.ProjectId, x.CreatedAt });
    }
}
