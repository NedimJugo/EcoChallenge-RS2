using EcoChallenge.Models.Messages;
using EcoChallenge.Subscriber.Services;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace EcoChallenge.Subscriber
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var host = CreateHostBuilder(args).Build();

            var logger = host.Services.GetRequiredService<ILogger<Program>>();
            logger.LogInformation("EcoChallenge Subscriber starting...");

            try
            {
                await host.RunAsync();
            }
            catch (Exception ex)
            {
                logger.LogCritical(ex, "Application terminated unexpectedly");
            }
        }

        static IHostBuilder CreateHostBuilder(string[] args) =>
            Host.CreateDefaultBuilder(args)
                .ConfigureAppConfiguration((context, config) =>
                {
                    bool isOptional = context.HostingEnvironment.IsDevelopment();
                    config.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
                    config.AddJsonFile($"appsettings.{context.HostingEnvironment.EnvironmentName}.json",
                        optional: true, reloadOnChange: true);
                    config.AddEnvironmentVariables();
                })
                .ConfigureServices((context, services) =>
                {
                    // Register services
                    services.AddSingleton<IEmailService, EmailService>();
                    services.AddSingleton<IRabbitMQConsumerService, RabbitMQConsumerService>();

                    // Register hosted service
                    services.AddHostedService<MessageConsumerHostedService>();
                });
    }
}
