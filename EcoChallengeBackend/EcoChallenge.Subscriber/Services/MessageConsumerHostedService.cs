using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Subscriber.Services
{
    public class MessageConsumerHostedService : BackgroundService
    {
        private readonly IRabbitMQConsumerService _consumerService;
        private readonly ILogger<MessageConsumerHostedService> _logger;

        public MessageConsumerHostedService(
            IRabbitMQConsumerService consumerService,
            ILogger<MessageConsumerHostedService> logger)
        {
            _consumerService = consumerService;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            _logger.LogInformation("Message Consumer Hosted Service starting");

            try
            {
                await _consumerService.StartConsumingAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogCritical(ex, "Message Consumer Hosted Service failed");
                throw;
            }
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            _logger.LogInformation("Message Consumer Hosted Service stopping");

            await _consumerService.StopConsumingAsync();
            await base.StopAsync(cancellationToken);
        }
    }
}
