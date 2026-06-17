using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;

namespace DataLabellingSupportSystem.Api.Database;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; } = default!;
    public DbSet<Role> Roles { get; set; } = default!;
    public DbSet<RefreshToken> RefreshTokens { get; set; } = default!;
    public DbSet<PasswordResetToken> PasswordResetTokens { get; set; } = default!;
    public DbSet<EmailVerificationOtp> EmailVerificationOtps { get; set; } = default!;

    public DbSet<Project> Projects { get; set; } = default!;
    public DbSet<Dataset> Datasets { get; set; } = default!;
    public DbSet<DataItem> DataItems { get; set; } = default!;
    public DbSet<Label> Labels { get; set; } = default!;
    public DbSet<LabelingTask> LabelingTasks { get; set; } = default!;
    public DbSet<AnnotationSet> AnnotationSets { get; set; } = default!;
    public DbSet<Annotation> Annotations { get; set; } = default!;
    public DbSet<TaskHistory> TaskHistories { get; set; } = default!;
    public DbSet<AiPrediction> AiPredictions { get; set; } = default!;
    public DbSet<Review> Reviews { get; set; } = default!;
    public DbSet<ReviewError> ReviewErrors { get; set; } = default!;
    public DbSet<ErrorType> ErrorTypes { get; set; } = default!;
    public DbSet<LabelCategory> LabelCategories { get; set; } = default!;
    public DbSet<AnnotationTypeDefinition> AnnotationTypeDefinitions { get; set; } = default!;
    public DbSet<UserProjectRole> UserProjectRoles { get; set; } = default!;
    public DbSet<DatasetVersion> DatasetVersions { get; set; } = default!;
    public DbSet<Export> Exports { get; set; } = default!;
    public DbSet<ExportConfig> ExportConfigs { get; set; } = default!;
    public DbSet<ActivityLog> ActivityLogs { get; set; } = default!;

    public override int SaveChanges()
    {
        ApplyAuditStamps();
        return base.SaveChanges();
    }

    public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        ApplyAuditStamps();
        return base.SaveChangesAsync(cancellationToken);
    }

    private void ApplyAuditStamps()
    {
        var now = DlssTime.VietnamNow;

        foreach (var entry in ChangeTracker.Entries<User>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<RefreshToken>())
        {
            if (entry.State == EntityState.Added && entry.Entity.CreatedAt == default)
            {
                entry.Entity.CreatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<PasswordResetToken>())
        {
            if (entry.State == EntityState.Added && entry.Entity.CreatedAt == default)
            {
                entry.Entity.CreatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<EmailVerificationOtp>())
        {
            if (entry.State == EntityState.Added && entry.Entity.CreatedAt == default)
            {
                entry.Entity.CreatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<Project>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<Dataset>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<DataItem>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<Label>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<LabelCategory>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<AnnotationTypeDefinition>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<LabelingTask>())
        {
            if (entry.State == EntityState.Added && string.IsNullOrWhiteSpace(entry.Entity.Id))
            {
                entry.Entity.Id = Utils.ObjectId.NewObjectId();
            }
        }

        foreach (var entry in ChangeTracker.Entries<Annotation>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
                entry.Entity.UpdatedAt = now;
            }
            else if (entry.State == EntityState.Modified)
            {
                entry.Entity.UpdatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<AnnotationSet>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<TaskHistory>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                if (entry.Entity.ChangedAt == default)
                {
                    entry.Entity.ChangedAt = now;
                }
            }
        }

        foreach (var entry in ChangeTracker.Entries<AiPrediction>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                entry.Entity.CreatedAt = now;
            }
        }

        foreach (var entry in ChangeTracker.Entries<Review>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                if (entry.Entity.ReviewedAt == default)
                {
                    entry.Entity.ReviewedAt = now;
                }
            }
        }

        foreach (var entry in ChangeTracker.Entries<DatasetVersion>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                if (entry.Entity.CreatedAt == default)
                {
                    entry.Entity.CreatedAt = now;
                }
            }
        }

        foreach (var entry in ChangeTracker.Entries<Export>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                if (entry.Entity.CreatedAt == default)
                {
                    entry.Entity.CreatedAt = now;
                }
            }
        }

        foreach (var entry in ChangeTracker.Entries<ActivityLog>())
        {
            if (entry.State == EntityState.Added)
            {
                if (string.IsNullOrWhiteSpace(entry.Entity.Id))
                {
                    entry.Entity.Id = Utils.ObjectId.NewObjectId();
                }

                if (entry.Entity.CreatedAt == default)
                {
                    entry.Entity.CreatedAt = now;
                }
            }
        }
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
    }
}
