using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.Services.Mapping;
using EcoChallenge.Services.Security;
using EcoChallenge.Services.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using System;

var builder = WebApplication.CreateBuilder(args);
//builder.Configuration
//    .SetBasePath(Directory.GetCurrentDirectory())
//    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
//    .AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true)
//    .AddEnvironmentVariables();
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=localhost;Database=EcoChallenge;Trusted_Connection=True;MultipleActiveResultSets=true;TrustServerCertificate=True";
builder.Services.AddDatabaseServices(connectionString);
builder.Services.AddAutoMapper(cfg => {}, typeof(UserProfile).Assembly, typeof(RequestProfile).Assembly, typeof(EventProfile).Assembly);

// Add services to the container.
builder.Services.AddSingleton<IPasswordHasher, Pbkdf2PasswordHasher>();
builder.Services.AddScoped<IRequestService, RequestService>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<IChallengeService, ChallengeService>();
builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
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
