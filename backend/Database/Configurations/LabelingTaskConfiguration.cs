using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class LabelingTaskConfiguration : IEntityTypeConfiguration<LabelingTask>
{
    public void Configure(EntityTypeBuilder<LabelingTask> builder)
    {
        builder.ToTable("tasks");

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
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.DataItemId)
            .HasColumnName("dataItemId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.DataItem)
            .WithMany()
            .HasForeignKey(x => x.DataItemId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.AnnotatorId)
            .HasColumnName("annotatorId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Annotator)
            .WithMany()
            .HasForeignKey(x => x.AnnotatorId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.AssignedByUserId)
            .HasColumnName("assignedBy")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24);

        builder.HasOne(x => x.AssignedByUser)
            .WithMany()
            .HasForeignKey(x => x.AssignedByUserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.Status)
            .HasColumnName("status")
            .HasColumnType("varchar(20)")
            .HasMaxLength(20)
            .HasDefaultValue("Assigned")
            .IsRequired();

        builder.Property(x => x.AssignedAt)
            .HasColumnName("assignedAt");

        builder.Property(x => x.CompletedAt)
            .HasColumnName("completedAt");

        builder.HasIndex(x => x.AnnotatorId);
        builder.HasIndex(x => x.DataItemId);
    }
}
