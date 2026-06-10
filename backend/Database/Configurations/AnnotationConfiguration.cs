using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class AnnotationConfiguration : IEntityTypeConfiguration<Annotation>
{
    public void Configure(EntityTypeBuilder<Annotation> builder)
    {
        builder.ToTable("Annotations");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.AnnotationSetId)
            .HasColumnName("annotationSetId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.AnnotationSet)
            .WithMany(x => x.Annotations)
            .HasForeignKey(x => x.AnnotationSetId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.LabelId)
            .HasColumnName("labelId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Label)
            .WithMany()
            .HasForeignKey(x => x.LabelId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.AnnotationType)
            .HasColumnName("annotationType")
            .HasColumnType("varchar(50)")
            .HasMaxLength(50)
            .IsRequired();

        builder.Property(x => x.GeometryData)
            .HasColumnName("geometryData")
            .HasColumnType("nvarchar(max)")
            .IsRequired();

        builder.Property(x => x.Version)
            .HasColumnName("version")
            .HasDefaultValue(1)
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("createdAt")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.Property(x => x.UpdatedAt)
            .HasColumnName("updatedAt")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.HasIndex(x => x.AnnotationSetId);
        builder.HasIndex(x => x.LabelId);
    }
}
