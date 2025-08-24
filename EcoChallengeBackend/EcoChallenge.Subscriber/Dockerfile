FROM mcr.microsoft.com/dotnet/runtime:9.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore
RUN dotnet build "EcoChallenge.Subscriber/EcoChallenge.Subscriber.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "EcoChallenge.Subscriber/EcoChallenge.Subscriber.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "EcoChallenge.Subscriber.dll"]