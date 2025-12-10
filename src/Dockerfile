# Sample Dockerfile for ASP.NET Core 6 Web App
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
WORKDIR /src
COPY ["ZavaStorefront.csproj", "."]
RUN dotnet restore "ZavaStorefront.csproj"
COPY . .
RUN dotnet publish "ZavaStorefront.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ZavaStorefront.dll"]
