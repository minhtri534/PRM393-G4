using DataLabellingSupportSystem.Api.Configurations;
using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Models;
using DataLabellingSupportSystem.Api.Services.Auth;
using DataLabellingSupportSystem.Api.Utils;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace DataLabellingSupportSystem.Api.Services.DevSeed;

public sealed class DevSeedHostedService(
    IServiceScopeFactory scopeFactory,
    IHostEnvironment environment,
    IOptions<DevSeedOptions> options,
    ILogger<DevSeedHostedService> logger) : IHostedService
{
    private const string AdminRoleId = "000000000000000000000001";
    private const string ManagerRoleId = "000000000000000000000002";
    private const string AnnotatorRoleId = "000000000000000000000003";
    private const string ReviewerRoleId = "000000000000000000000004";

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        if (!environment.IsDevelopment())
        {
            return;
        }

        var opt = options.Value;
        if (!opt.Enabled)
        {
            return;
        }

        try
        {
            using var scope = scopeFactory.CreateScope();
            var dbContext = scope.ServiceProvider.GetRequiredService<AppDbContext>();
            var passwordHasher = scope.ServiceProvider.GetRequiredService<IPasswordHasher>();

            await dbContext.Database.MigrateAsync(cancellationToken);

            // 0. Seed Roles
            var roles = new[]
            {
                new Role { Id = AdminRoleId, Name = "Admin" },
                new Role { Id = ManagerRoleId, Name = "Manager" },
                new Role { Id = AnnotatorRoleId, Name = "Annotator" },
                new Role { Id = ReviewerRoleId, Name = "Reviewer" }
            };

            foreach (var r in roles)
            {
                var exists = await dbContext.Roles.AnyAsync(x => x.Id == r.Id, cancellationToken);
                if (!exists)
                {
                    dbContext.Roles.Add(r);
                }
            }
            await dbContext.SaveChangesAsync(cancellationToken);

            // 1. Seed Admin
            var adminEmail = (opt.AdminEmail ?? "admin@demo.local").Trim().ToLowerInvariant();
            var admin = await dbContext.Users.FirstOrDefaultAsync(x => x.Email == adminEmail, cancellationToken);
            if (admin is null)
            {
                admin = new User
                {
                    FullName = (opt.AdminFullName ?? "System Administrator").Trim(),
                    Email = adminEmail,
                    PasswordHash = passwordHasher.Hash(opt.AdminPassword ?? "Password123!"),
                    RoleId = AdminRoleId,
                    Status = 0
                };
                dbContext.Users.Add(admin);
                logger.LogInformation("Seeding Admin user: {Email}", adminEmail);
            }

            // 2. Seed Manager
            var managerEmail = (opt.ManagerEmail ?? "manager@demo.local").Trim().ToLowerInvariant();
            var manager = await dbContext.Users.FirstOrDefaultAsync(x => x.Email == managerEmail, cancellationToken);
            if (manager is null)
            {
                manager = new User
                {
                    FullName = (opt.ManagerFullName ?? "Demo Manager").Trim(),
                    Email = managerEmail,
                    PasswordHash = passwordHasher.Hash(opt.ManagerPassword ?? "Password123!"),
                    RoleId = ManagerRoleId,
                    Status = 0
                };
                dbContext.Users.Add(manager);
                logger.LogInformation("Seeding Manager user: {Email}", managerEmail);
            }

            // 3. Seed Reviewer
            var reviewerEmail = (opt.ReviewerEmail ?? "reviewer@demo.local").Trim().ToLowerInvariant();
            var reviewer = await dbContext.Users.FirstOrDefaultAsync(x => x.Email == reviewerEmail, cancellationToken);
            if (reviewer is null)
            {
                reviewer = new User
                {
                    FullName = (opt.ReviewerFullName ?? "Demo Reviewer").Trim(),
                    Email = reviewerEmail,
                    PasswordHash = passwordHasher.Hash(opt.ReviewerPassword ?? "Password123!"),
                    RoleId = ReviewerRoleId,
                    Status = 0
                };
                dbContext.Users.Add(reviewer);
                logger.LogInformation("Seeding Reviewer user: {Email}", reviewerEmail);
            }

            // 4. Seed Annotator
            var normalizedEmail = (opt.AnnotatorEmail ?? string.Empty).Trim().ToLowerInvariant();
            if (string.IsNullOrWhiteSpace(normalizedEmail))
            {
                logger.LogWarning("Dev seed skipped: AnnotatorEmail is empty");
                return;
            }

            var annotator = await dbContext.Users.FirstOrDefaultAsync(x => x.Email == normalizedEmail, cancellationToken);
            if (annotator is null)
            {
                annotator = new User
                {
                    FullName = (opt.AnnotatorFullName ?? string.Empty).Trim(),
                    Email = normalizedEmail,
                    PasswordHash = passwordHasher.Hash(opt.AnnotatorPassword ?? "Password123!"),
                    RoleId = AnnotatorRoleId,
                    Status = 0
                };

                dbContext.Users.Add(annotator);
                logger.LogInformation("Seeding Annotator user: {Email}", normalizedEmail);
            }

            await dbContext.SaveChangesAsync(cancellationToken);

            var projectName = (opt.ProjectName ?? "Demo Project").Trim();
            var project = await dbContext.Projects
                .FirstOrDefaultAsync(x => x.Name == projectName, cancellationToken);

            if (project is null)
            {
                project = new Project
                {
                    Name = projectName,
                    Guideline = "Demo guideline:\n- Draw tight bounding boxes around the object.\n- If partially occluded, box the visible part only.\n- Ignore objects smaller than 20x20 px.",
                    Status = 0
                };

                dbContext.Projects.Add(project);
                await dbContext.SaveChangesAsync(cancellationToken);
            }
            else if (string.IsNullOrWhiteSpace(project.Guideline))
            {
                project.Guideline = "Demo guideline:\n- Draw tight bounding boxes around the object.\n- If partially occluded, box the visible part only.\n- Ignore objects smaller than 20x20 px.";
                await dbContext.SaveChangesAsync(cancellationToken);
            }

            // Assign Roles to Project
            var projectRoles = new[]
            {
                new { UserId = annotator.Id, RoleId = AnnotatorRoleId },
                new { UserId = reviewer.Id, RoleId = ReviewerRoleId },
                new { UserId = manager.Id, RoleId = ManagerRoleId }
            };

            foreach (var pr in projectRoles)
            {
                var exists = await dbContext.UserProjectRoles
                    .AsNoTracking()
                    .AnyAsync(x => x.UserId == pr.UserId && x.ProjectId == project.Id && x.RoleId == pr.RoleId, cancellationToken);

                if (!exists)
                {
                    dbContext.UserProjectRoles.Add(new UserProjectRole
                    {
                        UserId = pr.UserId,
                        ProjectId = project.Id,
                        RoleId = pr.RoleId
                    });
                }
            }
            await dbContext.SaveChangesAsync(cancellationToken);

            // Idempotency guard: if the demo annotator already has any task, don't create more demo tasks.
            var hasAnyTask = await dbContext.LabelingTasks
                .AsNoTracking()
                .AnyAsync(x => x.AnnotatorId == annotator.Id, cancellationToken);
            if (hasAnyTask)
            {
                return;
            }

            var datasetName = (opt.DatasetName ?? "Demo Dataset").Trim();
            var dataset = await dbContext.Datasets
                .FirstOrDefaultAsync(x => x.ProjectId == project.Id && x.Name == datasetName, cancellationToken);

            if (dataset is null)
            {
                dataset = new Dataset
                {
                    ProjectId = project.Id,
                    Name = datasetName
                };

                dbContext.Datasets.Add(dataset);
                await dbContext.SaveChangesAsync(cancellationToken);
            }

            var desiredLabels = new[]
            {
                // Align with common COCO class ids for YOLO pretrained models
                new { Name = "person", YoloClassId = 0 },
                new { Name = "car", YoloClassId = 2 }
            };

            foreach (var desired in desiredLabels)
            {
                var exists = await dbContext.Labels
                    .AsNoTracking()
                    .AnyAsync(x => x.ProjectId == project.Id && x.Name == desired.Name, cancellationToken);

                if (!exists)
                {
                    dbContext.Labels.Add(new Label
                    {
                        ProjectId = project.Id,
                        Name = desired.Name,
                        YoloClassId = desired.YoloClassId
                    });
                }
            }

            var desiredDataItems = new[]
            {
                new { StorageProvider = "RemoteUrl", ObjectKey = "https://i.postimg.cc/nCyjGV1J/0001.jpg", OriginalWidth = 1920, OriginalHeight = 1080 },
                new { StorageProvider = "RemoteUrl", ObjectKey = "https://i.postimg.cc/bs7D9YRq/0002.jpg", OriginalWidth = 1280, OriginalHeight = 720 },
                new { StorageProvider = "RemoteUrl", ObjectKey = "https://i.postimg.cc/1fknrRKR/0003.jpg", OriginalWidth = 1024, OriginalHeight = 768 }
            };

            foreach (var desired in desiredDataItems)
            {
                var exists = await dbContext.DataItems
                    .AsNoTracking()
                    .AnyAsync(x => x.DatasetId == dataset.Id && x.ObjectKey == desired.ObjectKey, cancellationToken);

                if (!exists)
                {
                    dbContext.DataItems.Add(new DataItem
                    {
                        DatasetId = dataset.Id,
                        StorageProvider = desired.StorageProvider,
                        ObjectKey = desired.ObjectKey,
                        OriginalWidth = desired.OriginalWidth,
                        OriginalHeight = desired.OriginalHeight
                    });
                }
            }

            await dbContext.SaveChangesAsync(cancellationToken);

            var dataItems = await dbContext.DataItems
                .AsNoTracking()
                .Where(x => x.DatasetId == dataset.Id && desiredDataItems.Select(d => d.ObjectKey).Contains(x.ObjectKey))
                .OrderBy(x => x.ObjectKey)
                .ToListAsync(cancellationToken);

            var now = DlssTime.VietnamNow;

            foreach (var dataItem in dataItems)
            {
                dbContext.LabelingTasks.Add(new LabelingTask
                {
                    ProjectId = project.Id,
                    DataItemId = dataItem.Id,
                    AnnotatorId = annotator.Id,
                    Status = "Assigned",
                    AssignedAt = now
                });
            }

            await dbContext.SaveChangesAsync(cancellationToken);

            logger.LogInformation(
                "Dev seed completed. Annotator email: {Email}. ProjectId: {ProjectId}. TasksCreated={Tasks}",
                annotator.Email,
                project.Id,
                dataItems.Count);
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Dev seed failed");
        }
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
