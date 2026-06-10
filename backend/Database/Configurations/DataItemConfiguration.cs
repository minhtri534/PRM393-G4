using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class DataItemConfiguration : IEntityTypeConfiguration<DataItem>
{
    public void Configure(EntityTypeBuilder<DataItem> builder)
    {
        builder.ToTable("DataItems");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.DatasetId)
            .HasColumnName("datasetId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Dataset)
            .WithMany()
            .HasForeignKey(x => x.DatasetId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.StorageProvider)
            .HasColumnName("storageProvider")
            .HasMaxLength(20)
            .IsRequired();

        builder.Property(x => x.ObjectKey)
            .HasColumnName("filePath")
            .HasMaxLength(500)
            .IsRequired();

        builder.Property(x => x.OriginalWidth)
            .HasColumnName("width")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(x => x.OriginalHeight)
            .HasColumnName("height")
            .HasDefaultValue(0)
            .IsRequired();

        builder.Property(x => x.DataType)
            .HasColumnName("dataType")
            .HasColumnType("varchar(50)")
            .HasMaxLength(50)
            .HasDefaultValue("Image")
            .IsRequired();

        builder.Property(x => x.Checksum)
            .HasColumnName("checksum")
            .HasColumnType("varchar(64)")
            .HasMaxLength(64);

        builder.Property(x => x.Status)
            .HasColumnName("status")
            .HasColumnType("varchar(20)")
            .HasMaxLength(20)
            .HasDefaultValue("Active")
            .IsRequired();

        builder.Property(x => x.UploadedByUserId)
            .HasColumnName("uploadedBy")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.HasOne(x => x.UploadedByUser)
            .WithMany()
            .HasForeignKey(x => x.UploadedByUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.CreatedAt)
            .HasColumnName("createdAt")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.Property(x => x.UpdatedAt)
            .HasColumnName("updatedAt")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();
    }
}
