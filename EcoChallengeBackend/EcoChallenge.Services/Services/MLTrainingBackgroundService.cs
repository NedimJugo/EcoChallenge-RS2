using EcoChallenge.Services.Interfeces;
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
    public class MLTrainingBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<MLTrainingBackgroundService> _logger;
        private readonly TimeSpan _period = TimeSpan.FromHours(24); // Retrain daily

        public MLTrainingBackgroundService(IServiceProvider serviceProvider, ILogger<MLTrainingBackgroundService> logger)
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
                    var mlService = scope.ServiceProvider.GetRequiredService<IMLPricingService>();

                    await mlService.TrainModelAsync();
                    _logger.LogInformation("ML model training completed at {Time}", DateTime.UtcNow);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error during scheduled ML training");
                }

                await Task.Delay(_period, stoppingToken);
            }
        }
    }
}
