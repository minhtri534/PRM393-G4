FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src

COPY ["backend/DataLabellingSupportSystem.Api.csproj", "backend/"]
RUN dotnet restore "backend/DataLabellingSupportSystem.Api.csproj"

COPY backend/ ./backend/
WORKDIR "/src/backend"
RUN dotnet publish "DataLabellingSupportSystem.Api.csproj" -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /out .

ENV ASPNETCORE_URLS=http://0.0.0.0:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "DataLabellingSupportSystem.Api.dll"]
