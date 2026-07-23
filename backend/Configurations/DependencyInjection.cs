using DataLabellingSupportSystem.Api.Database;
using DataLabellingSupportSystem.Api.Middlewares;
using DataLabellingSupportSystem.Api.Services.Annotator;
using DataLabellingSupportSystem.Api.Services.Auth;
using DataLabellingSupportSystem.Api.Services.AiAssist;
using DataLabellingSupportSystem.Api.Services.DevSeed;
using DataLabellingSupportSystem.Api.Services.Email;
using DataLabellingSupportSystem.Api.Services.Exports;
using DataLabellingSupportSystem.Api.Services.Roles;
using DataLabellingSupportSystem.Api.Services.Storage;
using DataLabellingSupportSystem.Api.Services.Users;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using DataLabellingSupportSystem.Api.Services.Reviews;
using DataLabellingSupportSystem.Api.Repository;
using DataLabellingSupportSystem.Api.Services.ErrorTypes;
using DataLabellingSupportSystem.Api.Services.ReviewErrors;
using DataLabellingSupportSystem.Api.Services.LabelingTasks;
using DataLabellingSupportSystem.Api.Services.Manager;
using DataLabellingSupportSystem.Api.Services.Admin;
using DataLabellingSupportSystem.Api.Services.Projects;
using DataLabellingSupportSystem.Api.Services.Chat;
using DataLabellingSupportSystem.Api.Services.Notifications;
using DataLabellingSupportSystem.Api.Services.Realtime;

namespace DataLabellingSupportSystem.Api.Configurations;

public static class DependencyInjection
{
    public static IServiceCollection AddDlssControllersAndValidation(this IServiceCollection services)
    {
        services.AddControllers();
        services.AddFluentValidationAutoValidation();
        services.AddValidatorsFromAssembly(typeof(Program).Assembly);
        services.AddEndpointsApiExplorer();
        return services;
    }

    public static IServiceCollection AddDlssSwagger(this IServiceCollection services)
    {
        services.AddSwaggerGen(options =>
        {
            options.CustomSchemaIds(type => BuildSwaggerSchemaId(type));

            var bearerScheme = new Microsoft.OpenApi.OpenApiSecurityScheme
            {
                Name = "Authorization",
                Type = Microsoft.OpenApi.SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                In = Microsoft.OpenApi.ParameterLocation.Header,
                Description = "Paste only the JWT access token here. Swagger will send: Authorization: Bearer <token>"
            };

            options.AddSecurityDefinition("Bearer", bearerScheme);

            options.AddSecurityRequirement(document => new Microsoft.OpenApi.OpenApiSecurityRequirement
            {
                { new Microsoft.OpenApi.OpenApiSecuritySchemeReference("Bearer", document, null), new List<string>() }
            });
        });

        return services;
    }

    private static string BuildSwaggerSchemaId(Type type)
    {
        if (!type.IsGenericType)
        {
            return (type.FullName ?? type.Name).Replace('+', '.');
        }

        var genericTypeName = type.GetGenericTypeDefinition().FullName ?? type.Name;
        genericTypeName = genericTypeName[..genericTypeName.IndexOf('`')].Replace('+', '.');
        var genericArgNames = string.Join("_", type.GetGenericArguments().Select(BuildSwaggerSchemaId));

        return $"{genericTypeName}_{genericArgNames}";
    }

    public static IServiceCollection AddDlssDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
            options.UseSqlServer(configuration.GetConnectionString("DefaultConnection")));

        return services;
    }

    public static IServiceCollection AddDlssDomainServices(this IServiceCollection services)
    {
        services.AddScoped<IUsersService, UsersService>();
        services.AddScoped<IRolesService, RolesService>();
        services.AddScoped<IAnnotatorService, AnnotatorService>();
        services.AddScoped<IAiAssistService, AiAssistService>();
        services.AddScoped<IExportService, ExportService>();
        services.AddScoped<ReviewsRepository>();
        services.AddScoped<IReviewsService, ReviewsService>();
        services.AddScoped<IReviewerWorkflowService, ReviewerWorkflowService>();
        services.AddScoped<ReviewErrorsRepository>();
        services.AddScoped<IReviewErrorsService, ReviewErrorsService>();
        services.AddScoped<ErrorTypesRepository>();
        services.AddScoped<IErrorTypesService, ErrorTypesService>();
        services.AddScoped<LabelingTasksRepository>();
        services.AddScoped<ILabelingTasksService, LabelingTasksService>();
        services.AddScoped<IManagerService, ManagerService>();
        services.AddScoped<IAdminService, AdminService>();
        services.AddScoped<IProjectMembershipService, ProjectMembershipService>();
        services.AddScoped<IChatService, ChatService>();
        services.AddScoped<INotificationService, NotificationService>();
        services.AddSingleton<IRealtimePublisher, RealtimePublisher>();
        services.AddHostedService<DevSeedHostedService>();
        return services;
    }

    public static IServiceCollection AddDlssRealtime(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<RealtimeOptions>(configuration.GetSection("Realtime"));
        services.AddHttpClient("Realtime", client =>
        {
            client.Timeout = TimeSpan.FromSeconds(5);
        });
        return services;
    }

    public static IServiceCollection AddDlssAiAssist(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<AiAssistOptions>(configuration.GetSection("AiAssist"));

        services.AddHttpClient<HttpYoloInferenceClient>((sp, http) =>
        {
            var opt = sp.GetRequiredService<Microsoft.Extensions.Options.IOptions<AiAssistOptions>>().Value;
            http.BaseAddress = new Uri(opt.BaseUrl);
            http.Timeout = TimeSpan.FromSeconds(Math.Max(1, opt.TimeoutSeconds));
        });

        services.AddScoped<IYoloInferenceClient>(sp => sp.GetRequiredService<HttpYoloInferenceClient>());
        return services;
    }

    public static IServiceCollection AddDlssStorage(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<StorageOptions>(configuration.GetSection("Storage"));
        services.AddScoped<IStorageService, LocalStorageService>();
        return services;
    }

    public static IServiceCollection AddDlssAuth(this IServiceCollection services, IConfiguration configuration)
    {
        services.Configure<JwtOptions>(configuration.GetSection("Jwt"));
        services.Configure<GoogleAuthOptions>(configuration.GetSection("GoogleAuth"));
        services.Configure<DevSeedOptions>(configuration.GetSection("DevSeed"));
        services.Configure<EmailOptions>(configuration.GetSection("Email"));

        services.AddSingleton<IPasswordHasher, PasswordHasher>();
        services.AddSingleton<ISecureTokenGenerator, SecureTokenGenerator>();
        services.AddSingleton<IJwtTokenService, JwtTokenService>();
        services.AddSingleton<IGoogleIdTokenValidator, GoogleIdTokenValidator>();

        var emailProvider = configuration.GetSection("Email").GetValue<string>("Provider") ?? "Console";
        if (string.Equals(emailProvider, "Smtp", StringComparison.OrdinalIgnoreCase))
        {
            services.AddSingleton<IEmailSender, SmtpEmailSender>();
        }
        else
        {
            services.AddSingleton<IEmailSender, ConsoleEmailSender>();
        }

        services.AddScoped<IAuthService, AuthService>();

        var jwt = configuration.GetSection("Jwt").Get<JwtOptions>() ?? new JwtOptions();
        var signingKeyBytes = Encoding.UTF8.GetBytes(jwt.SigningKey ?? string.Empty);

        services
            .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
            .AddJwtBearer(options =>
            {
                options.MapInboundClaims = false;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwt.Issuer,
                    ValidateAudience = true,
                    ValidAudience = jwt.Audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(signingKeyBytes),
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    // MapInboundClaims=false keeps JWT claim names as-is; roleName is always emitted.
                    RoleClaimType = "roleName"
                };
            });

        services.AddAuthorization();

        return services;
    }

    public static IServiceCollection AddDlssCors(this IServiceCollection services)
    {
        services.AddCors(options =>
        {
            options.AddPolicy("AllowFrontend", policy =>
            {
                policy.WithOrigins("http://localhost:5173")
                    .AllowAnyMethod()
                    .AllowAnyHeader()
                    .AllowCredentials();
            });
        });

        return services;
    }

    public static WebApplication UseDlssPipeline(this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI();
        }

        var hasHttpsUrl = app.Urls.Any(url => url.StartsWith("https://", StringComparison.OrdinalIgnoreCase));
        if (hasHttpsUrl)
        {
            app.UseHttpsRedirection();
        }

        app.UseCors("AllowFrontend");
        app.UseMiddleware<GlobalExceptionHandler>();
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapControllers();
        return app;
    }
}
