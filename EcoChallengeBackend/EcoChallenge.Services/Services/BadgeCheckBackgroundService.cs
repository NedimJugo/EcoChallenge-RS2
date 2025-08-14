using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore; // Add this using directive
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class BadgeCheckBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<BadgeCheckBackgroundService> _logger;
        private readonly TimeSpan _period = TimeSpan.FromHours(24);

        public BadgeCheckBackgroundService(
            IServiceProvider serviceProvider,
            ILogger<BadgeCheckBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            while (!stoppingToken.IsCancellationRequested)
            {
                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var context = scope.ServiceProvider.GetRequiredService<EcoChallengeDbContext>();
                    var badgeService = scope.ServiceProvider.GetRequiredService<IBadgeManagementService>();

                    // Get all active users
                    var userIds = await context.Users
                        .Where(u => u.IsActive) // Assuming you have an IsActive property
                        .Select(u => u.Id)
                        .ToListAsync(stoppingToken);

                    _logger.LogInformation("Starting daily badge check for {UserCount} users", userIds.Count);

                    foreach (var userId in userIds)
                    {
                        try
                        {
                            await badgeService.CheckAndAwardBadgesAsync(userId);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Error checking badges for user {UserId}", userId);
                        }
                    }

                    _logger.LogInformation("Daily badge check completed for {UserCount} users", userIds.Count);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error during daily badge check");
                }

                await Task.Delay(_period, stoppingToken);
            }
        }
    }
}