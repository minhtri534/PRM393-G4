using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class AnnotationSetConfiguration : IEntityTypeConfiguration<AnnotationSet>
{
    public void Configure(EntityTypeBuilder<AnnotationSet> builder)
    {
        builder.ToTable("AnnotationSets");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("Id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.TaskId)
            .HasColumnName("TaskId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Task)
            .WithMany()
            .HasForeignKey(x => x.TaskId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.CreatedByUserId)
            .HasColumnName("CreatedByUserId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.CreatedByUser)
            .WithMany()
            .HasForeignKey(x => x.CreatedByUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.Status)
            .HasColumnName("Status")
            .HasColumnType("nvarchar(max)")
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("CreatedAt");

        builder.HasIndex(x => x.TaskId);
        builder.HasIndex(x => x.CreatedByUserId);
    }
}
