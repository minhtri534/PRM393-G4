using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class NotificationConfiguration : IEntityTypeConfiguration<Notification>
{
    public void Configure(EntityTypeBuilder<Notification> builder)
    {
        builder.ToTable("notifications");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("notification_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.RecipientUserId)
            .HasColumnName("recipient_user_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.ActorUserId)
            .HasColumnName("actor_user_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.Property(x => x.ProjectId)
            .HasColumnName("project_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.Property(x => x.Type)
            .HasColumnName("type")
            .HasColumnType("varchar(40)")
            .HasMaxLength(40)
            .IsRequired();

        builder.Property(x => x.Title)
            .HasColumnName("title")
            .HasColumnType("nvarchar(200)")
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(x => x.Body)
            .HasColumnName("body")
            .HasColumnType("nvarchar(1000)")
            .HasMaxLength(1000);

        builder.Property(x => x.RelatedEntityId)
            .HasColumnName("related_entity_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.Property(x => x.IsRead)
            .HasColumnName("is_read")
            .HasDefaultValue(false)
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasOne(x => x.RecipientUser)
            .WithMany()
            .HasForeignKey(x => x.RecipientUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.ActorUser)
            .WithMany()
            .HasForeignKey(x => x.ActorUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(x => new { x.RecipientUserId, x.IsRead, x.CreatedAt });
        builder.HasIndex(x => new { x.RecipientUserId, x.CreatedAt });
    }
}
