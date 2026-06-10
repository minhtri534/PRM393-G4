using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class ExportConfigConfiguration : IEntityTypeConfiguration<ExportConfig>
{
    public void Configure(EntityTypeBuilder<ExportConfig> builder)
    {
        builder.ToTable("export_configs");

        builder.HasKey(x => x.ExportId);

        builder.Property(x => x.ExportId)
            .HasColumnName("export_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.LabelFormat)
            .HasColumnName("label_format")
            .HasColumnType("varchar(100)")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(x => x.IncludeFields)
            .HasColumnName("include_fields")
            .HasColumnType("nvarchar(max)")
            .IsRequired();

        builder.Property(x => x.Filters)
            .HasColumnName("filters")
            .HasColumnType("nvarchar(max)")
            .IsRequired();
    }
}
