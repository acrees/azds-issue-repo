FROM mcr.microsoft.com/dotnet/core/aspnet:3.1 AS base
WORKDIR /app
EXPOSE 80

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
WORKDIR /build
COPY ["azds-issue-repo.sln", "."]
COPY ["src/domain/domain.csproj", "./src/domain/domain.csproj"]
COPY ["src/web/web.csproj", "./src/web/web.csproj"]
COPY ["test/domain.test/domain.test.csproj", "./test/domain.test/domain.test.csproj"]
RUN dotnet restore
COPY . .

RUN dotnet test "test/domain.test"

RUN dotnet build "src/web" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "src/web" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "web.dll"]