using DataLabellingSupportSystem.Api.Configurations;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddDlssControllersAndValidation()
    .AddDlssSwagger()
    .AddDlssDatabase(builder.Configuration)
    .AddDlssDomainServices()
    .AddDlssAiAssist(builder.Configuration)
    .AddDlssStorage(builder.Configuration)
    .AddDlssAuth(builder.Configuration);

builder.Services.AddCors(options => {
    options.AddPolicy("AllowFrontend", policy => {
        // Allow localhost and machine IP for multi-machine testing
        policy.SetIsOriginAllowed(origin => {
            // Allow localhost and loopback
            if (origin.Contains("localhost", StringComparison.OrdinalIgnoreCase) ||
                origin.Contains("127.0.0.1") ||
                origin.Contains("0.0.0.0"))
                return true;
            
            // Allow from config if specified
            var allowedOrigins = builder.Configuration.GetSection("AllowedOrigins").Get<string[]>();
            return allowedOrigins?.Contains(origin) ?? false;
        })
              .AllowAnyHeader()
              .AllowAnyMethod()
              .AllowCredentials();
    });
});

var app = builder.Build();

app.UseCors("AllowFrontend"); 
app.UseDlssPipeline();

app.Run();