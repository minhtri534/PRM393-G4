using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class DatasetVersionConfiguration : IEntityTypeConfiguration<DatasetVersion>
{
    public void Configure(EntityTypeBuilder<DatasetVersion> builder)
    {
        builder.ToTable("dataset_versions");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("version_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.DatasetId)
            .HasColumnName("dataset_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Dataset)
            .WithMany()
            .HasForeignKey(x => x.DatasetId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.VersionName)
            .HasColumnName("version_name")
            .HasMaxLength(150)
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("created_at")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasIndex(x => new { x.DatasetId, x.VersionName }).IsUnique();
    }
}
