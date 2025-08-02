using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.Services.Mapping;
using EcoChallenge.Services.Security;
using EcoChallenge.Services.Services;
using EcoChallenge.WebAPI.Filters;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.OpenApi.Models;
using System;

var builder = WebApplication.CreateBuilder(args);
builder.Configuration
    .SetBasePath(Directory.GetCurrentDirectory())
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
    .AddEnvironmentVariables();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=localhost;Database=EcoChallenge;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";
builder.Services.AddDatabaseServices(connectionString);
builder.Services.AddAutoMapper(cfg => { }, typeof(UserProfile).Assembly, typeof(RequestProfile).Assembly,
    typeof(EventProfile).Assembly, typeof(UserTypeProfile).Assembly, typeof(BadgeProfile).Assembly,
    typeof(LocationProfile).Assembly, typeof(UserBadgeProfile).Assembly, typeof(WasteTypeProfile).Assembly,
    typeof(RewardProfile).Assembly, typeof(DonationProfile).Assembly, typeof(BalanceSettingProfile).Assembly,
    typeof(GalleryReactionProfile).Assembly, typeof(GalleryShowcaseProfile).Assembly, typeof(EventParticipantProfile).Assembly);

builder.Services.AddAuthentication("BasicAuthentication")
    .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

// Add services to the container.
builder.Services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
builder.Services.AddScoped<IRequestService, RequestService>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IOrganizationService, OrganizationService>();
builder.Services.AddScoped<IAdminAuthService, AdminAuthService>();
builder.Services.AddScoped<IOrganizationService, OrganizationService>();
builder.Services.AddScoped<IUserTypeService, UserTypeService>();
builder.Services.AddScoped<IBadgeService, BadgeService>();
builder.Services.AddScoped<ILocationService, LocationService>();
builder.Services.AddScoped<IUserBadgeService, UserBadgeService>();
builder.Services.AddScoped<IWasteTypeService, WasteTypeService>();
builder.Services.AddScoped<IDonationService, DonationService>();
builder.Services.AddScoped<IRewardService, RewardService>();
builder.Services.AddScoped<IGalleryReactionService, GalleryReactionService>();
builder.Services.AddScoped<IGalleryShowcaseService, GalleryShowcaseService>();
builder.Services.AddScoped<IEventParticipantService, EventParticipantService>();
builder.Services.AddScoped<IBalanceSettingService, BalanceSettingService>();
builder.Services.AddScoped<IStripeService, StripeService>();
builder.Services.AddScoped<IBlobService, BlobService>();
builder.Services.AddControllers();

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("BasicAuthentication", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "basic",
        In = ParameterLocation.Header,
        Description = "Basic Authorization header using the Bearer scheme."
    });
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
        new OpenApiSecurityScheme { Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "BasicAuthentication" }},
        new string[] {}
        }
    });
});


var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<EcoChallengeDbContext>();
    dbContext.Database.EnsureCreated();
}


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
