using DataLabellingSupportSystem.Api.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace DataLabellingSupportSystem.Api.Database.Configurations;

public sealed class ReviewConfiguration : IEntityTypeConfiguration<Review>
{
    public void Configure(EntityTypeBuilder<Review> builder)
    {
        builder.HasOne(x => x.Reviewer)
            .WithMany()
            .HasForeignKey(x => x.ReviewerId)
            .HasPrincipalKey(x => x.Id)
            .OnDelete(DeleteBehavior.NoAction);
    }
}
