using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Database.ValueGenerators;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("Users");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Id)
            .HasColumnName("_id")
            .HasColumnType("varchar(24)")
            .HasSentinel(string.Empty)
            .ValueGeneratedOnAdd()
            .HasValueGenerator<ObjectIdValueGenerator>();

        builder.Property(x => x.FullName)
            .HasColumnName("fullName")
            .HasMaxLength(150)
            .IsRequired();

        builder.Property(x => x.Email)
            .HasColumnName("email")
            .HasMaxLength(320)
            .IsRequired();

        builder.HasIndex(x => x.Email)
            .IsUnique();

        builder.Property(x => x.PhoneNumber)
            .HasColumnName("phoneNumber")
            .HasMaxLength(20);

        builder.Property(x => x.IdentifyNumber)
            .HasColumnName("identifyNumber")
            .HasMaxLength(20);

        builder.Property(x => x.Gender)
            .HasColumnName("gender")
            .HasMaxLength(20);

        builder.Property(x => x.Address)
            .HasColumnName("address")
            .HasMaxLength(300);

        builder.Property(x => x.DateOfBirth)
            .HasColumnName("dateOfBirth")
            .HasColumnType("date");

        builder.Property(x => x.PasswordHash)
            .HasColumnName("passwordHash")
            .HasMaxLength(255)
            .IsRequired();

        builder.Property(x => x.RoleId)
            .HasColumnName("role")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.Role)
            .WithMany()
            .HasForeignKey(x => x.RoleId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Restrict);

        builder.Property(x => x.Status)
            .HasColumnName("status")
            .HasDefaultValue(0);

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
