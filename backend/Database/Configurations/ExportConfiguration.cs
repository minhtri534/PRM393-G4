using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class ExportConfiguration : IEntityTypeConfiguration<Export>
{
    public void Configure(EntityTypeBuilder<Export> builder)
    {
        builder.ToTable("exports");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("export_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.ProjectId)
            .HasColumnName("project_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.Format)
            .HasColumnName("format")
            .HasColumnType("varchar(50)")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.ExportedByUserId)
            .HasColumnName("exported_by")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.ExportedByUser)
            .WithMany()
            .HasForeignKey(x => x.ExportedByUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.ExportPath)
            .HasColumnName("export_path")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasOne(x => x.ExportConfig)
            .WithOne(x => x.Export)
            .HasForeignKey<ExportConfig>(x => x.ExportId)
            .HasPrincipalKey<Export>(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.ExportedByUserId);
    }
}
