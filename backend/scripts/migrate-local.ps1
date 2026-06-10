Param(
    [string]$ProjectPath = "DataLabellingSupportSystem.Api.csproj"
)

$ErrorActionPreference = "Stop"

if (-not $env:ConnectionStrings__DefaultConnection) {
    Write-Error "ConnectionStrings__DefaultConnection is not set."
}

dotnet restore $ProjectPath
dotnet ef database update --project $ProjectPath
