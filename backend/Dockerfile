FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["DataLabellingSupportSystem.Api.csproj", "./"]
RUN dotnet restore "DataLabellingSupportSystem.Api.csproj"

COPY . .
RUN dotnet publish "DataLabellingSupportSystem.Api.csproj" -c Release -o /out

FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .

ENV ASPNETCORE_URLS=http://0.0.0.0:5000
EXPOSE 5000

ENTRYPOINT ["dotnet", "DataLabellingSupportSystem.Api.dll"]
