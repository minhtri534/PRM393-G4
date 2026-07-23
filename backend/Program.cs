using DataLabellingSupportSystem.Api.Configurations;

var builder = WebApplication.CreateBuilder(args);

builder.Services
    .AddDlssControllersAndValidation()
    .AddDlssSwagger()
    .AddDlssDatabase(builder.Configuration)
    .AddDlssDomainServices()
    .AddDlssRealtime(builder.Configuration)
    .AddDlssAiAssist(builder.Configuration)
    .AddDlssStorage(builder.Configuration)
    .AddDlssAuth(builder.Configuration);

builder.Services.AddCors(options => {
    options.AddPolicy("AllowFrontend", policy => {
        // Allow localhost + LAN IPs so phones can open Flutter web on the same Wi-Fi
        policy.SetIsOriginAllowed(origin => {
            if (string.IsNullOrWhiteSpace(origin))
                return false;

            if (origin.Contains("localhost", StringComparison.OrdinalIgnoreCase) ||
                origin.Contains("127.0.0.1") ||
                origin.Contains("0.0.0.0"))
                return true;

            if (Uri.TryCreate(origin, UriKind.Absolute, out var uri))
            {
                var host = uri.Host;
                if (host.Contains("ngrok", StringComparison.OrdinalIgnoreCase))
                    return true;

                if (host.StartsWith("192.168.", StringComparison.Ordinal) ||
                    host.StartsWith("10.", StringComparison.Ordinal) ||
                    (host.StartsWith("172.", StringComparison.Ordinal) &&
                     int.TryParse(host.Split('.')[1], out var second) &&
                     second is >= 16 and <= 31))
                {
                    return true;
                }
            }

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