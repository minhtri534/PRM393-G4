using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class EmailVerificationOtpConfiguration : IEntityTypeConfiguration<EmailVerificationOtp>
{
    public void Configure(EntityTypeBuilder<EmailVerificationOtp> builder)
    {
        builder.ToTable("EmailVerificationOtps");

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Code)
            .HasColumnName("code")
            .HasMaxLength(10)
            .IsRequired();

        builder.HasIndex(x => new { x.UserId, x.Code });

        builder.Property(x => x.UserId)
            .HasColumnName("userId")
            .HasColumnType("varchar(24)")
            .HasMaxLength(24)
            .IsRequired();

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.Cascade);

        builder.Property(x => x.ExpiresAt)
            .HasColumnName("expiresAt")
            .IsRequired();

        builder.Property(x => x.CreatedAt)
            .HasColumnName("createdAt")
            .HasDefaultValueSql("DATEADD(HOUR, 7, SYSUTCDATETIME())")
            .IsRequired();

        builder.Property(x => x.UsedAt)
            .HasColumnName("usedAt");
    }
}
