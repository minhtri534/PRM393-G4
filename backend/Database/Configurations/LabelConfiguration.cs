using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class LabelConfiguration : IEntityTypeConfiguration<Label>
{
    public void Configure(EntityTypeBuilder<Label> builder)
    {
        builder.ToTable("label_classes");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.ProjectId)
            .HasColumnName("projectId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.Name)
            .HasColumnName("name")
            .HasMaxLength(100)
            .IsRequired();

        builder.Property(x => x.CategoryId)
            .HasColumnName("categoryId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.HasOne(x => x.Category)
            .WithMany()
            .HasForeignKey(x => x.CategoryId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.NoAction);

        builder.Property(x => x.AnnotationTypeId)
            .HasColumnName("annotationTypeId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.HasOne(x => x.AnnotationType)
            .WithMany()
            .HasForeignKey(x => x.AnnotationTypeId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.NoAction);

        builder.HasIndex(x => new { x.ProjectId, x.Name })
            .IsUnique();

        builder.Property(x => x.YoloClassId)
            .HasColumnName("yoloClassId")
            .HasDefaultValue(0)
            .IsRequired();

        builder.HasIndex(x => new { x.ProjectId, x.YoloClassId })
            .IsUnique();

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
