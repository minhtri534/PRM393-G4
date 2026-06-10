using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class ActivityLogConfiguration : IEntityTypeConfiguration<ActivityLog>
{
    public void Configure(EntityTypeBuilder<ActivityLog> builder)
    {
        builder.ToTable("activity_logs");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("log_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.UserId)
            .HasColumnName("user_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.Action)
            .HasColumnName("action")
            .HasColumnType("varchar(120)")
            .HasMaxLength(120)
            .IsRequired();

        builder.Property(x => x.TargetType)
            .HasColumnName("target_type")
            .HasColumnType("varchar(50)")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.TargetId)
            .HasColumnName("target_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasIndex(x => x.UserId);
        builder.HasIndex(x => new { x.TargetType, x.TargetId });
    }
}
