using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class DatasetConfiguration : IEntityTypeConfiguration<Dataset>
{
    public void Configure(EntityTypeBuilder<Dataset> builder)
    {
        builder.ToTable("Datasets");

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

        builder.Property(x => x.Name)
            .HasColumnName("name")
            .HasMaxLength(200)
            .IsRequired();

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
