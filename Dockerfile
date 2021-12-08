#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

# this is a super slim image, only the stuff we need to run in production (we don't need the compiler on our servers!)
FROM mcr.microsoft.com/dotnet/aspnet:6.0 AS base
WORKDIR /app
EXPOSE 80

# this is the full deal that has the ability to build, restore all that jazz
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build 
WORKDIR /src
COPY ["OnCallLookupApi.csproj", "."]
RUN dotnet restore "./OnCallLookupApi.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "OnCallLookupApi.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "OnCallLookupApi.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "OnCallLookupApi.dll"]