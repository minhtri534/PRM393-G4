using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class UserProjectRoleConfiguration : IEntityTypeConfiguration<UserProjectRole>
{
    public void Configure(EntityTypeBuilder<UserProjectRole> builder)
    {
        builder.ToTable("user_project_roles");

        builder.HasKey(x => new { x.UserId, x.ProjectId, x.RoleId });

        builder.Property(x => x.UserId)
            .HasColumnName("user_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.ProjectId)
            .HasColumnName("project_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.Property(x => x.RoleId)
            .HasColumnName("role_id")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Project)
            .WithMany()
            .HasForeignKey(x => x.ProjectId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(x => x.Role)
            .WithMany()
            .HasForeignKey(x => x.RoleId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(x => x.ProjectId);
        builder.HasIndex(x => x.RoleId);
    }
}
