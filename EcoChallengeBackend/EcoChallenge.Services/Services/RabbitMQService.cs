using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class RabbitMQService : IRabbitMQService, IDisposable
    {
        private readonly RabbitMQ.Client.IConnection _connection;
        private readonly RabbitMQ.Client.IModel _channel;
        private readonly ILogger<RabbitMQService> _logger;
        private readonly string _exchangeName;
        private bool _disposed = false;

        public RabbitMQService(IConfiguration configuration, ILogger<RabbitMQService> logger)
        {
            _logger = logger;

            var factory = new ConnectionFactory()
            {
                HostName = configuration["RabbitMQ:HostName"] ?? "localhost",
                Port = int.Parse(configuration["RabbitMQ:Port"] ?? "5672"),
                UserName = configuration["RabbitMQ:UserName"] ?? "guest",
                Password = configuration["RabbitMQ:Password"] ?? "guest",
                VirtualHost = configuration["RabbitMQ:VirtualHost"] ?? "/",

                // Connection resilience settings
                AutomaticRecoveryEnabled = true,
                NetworkRecoveryInterval = TimeSpan.FromSeconds(10),
                RequestedHeartbeat = TimeSpan.FromSeconds(60)
            };

            _exchangeName = configuration["RabbitMQ:ExchangeName"] ?? "ecochallenge.notifications";

            try
            {
                _connection = factory.CreateConnection("EcoChallenge-Publisher");
                _channel = _connection.CreateModel();

                // Declare exchange
                _channel.ExchangeDeclare(
                    exchange: _exchangeName,
                    type: ExchangeType.Topic,
                    durable: true,
                    autoDelete: false
                );

                // Declare queues
                DeclareQueues();

                _logger.LogInformation("RabbitMQ connection established successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to establish RabbitMQ connection");
                throw;
            }
        }

        private void DeclareQueues()
        {
            // Request status changed queue
            var requestQueueName = "ecochallenge.request.status.changed";
            _channel.QueueDeclare(
                queue: requestQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false
            );

            // Bind to multiple routing keys for request status changes
            var requestRoutingKeys = new[] {
                "request.status.approved",
                "request.status.denied",
                "request.status.changed"
            };

            foreach (var routingKey in requestRoutingKeys)
            {
                _channel.QueueBind(
                    queue: requestQueueName,
                    exchange: _exchangeName,
                    routingKey: routingKey
                );
            }

            // Proof status changed queue
            var proofQueueName = "ecochallenge.proof.status.changed";
            _channel.QueueDeclare(
                queue: proofQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false
             );

            // Bind to multiple routing keys for proof status changes
            var proofRoutingKeys = new[] {
                "proof.status.approved",
                "proof.status.denied",
                "proof.status.changed"
            };

            foreach (var routingKey in proofRoutingKeys)
            {
                _channel.QueueBind(
                    queue: proofQueueName,
                    exchange: _exchangeName,
                    routingKey: routingKey
                );
            }

            var passwordResetQueueName = "ecochallenge.password.reset.requested";
            _channel.QueueDeclare(
                queue: passwordResetQueueName,
                durable: true,
                exclusive: false,
                autoDelete: false
            );

            _channel.QueueBind(
                queue: passwordResetQueueName,
                exchange: _exchangeName,
                routingKey: "password.reset.requested"
            );
        }

        public async Task PublishAsync<T>(T message, string routingKey) where T : class
        {
            if (_disposed)
                throw new ObjectDisposedException(nameof(RabbitMQService));

            try
            {
                var json = JsonConvert.SerializeObject(message, new JsonSerializerSettings
                {
                    DateFormatHandling = DateFormatHandling.IsoDateFormat,
                    DateTimeZoneHandling = DateTimeZoneHandling.Utc
                });

                var body = Encoding.UTF8.GetBytes(json);

                var properties = _channel.CreateBasicProperties();
                properties.Persistent = true; // Make message persistent
                properties.ContentType = "application/json";
                properties.MessageId = Guid.NewGuid().ToString();
                properties.Timestamp = new AmqpTimestamp(DateTimeOffset.UtcNow.ToUnixTimeSeconds());
                properties.Type = typeof(T).Name;

                _channel.BasicPublish(
                    exchange: _exchangeName,
                    routingKey: routingKey,
                    basicProperties: properties,
                    body: body
                );

                _logger.LogInformation("Published message {MessageType} with routing key {RoutingKey}",
                    typeof(T).Name, routingKey);

                await Task.CompletedTask;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish message {MessageType} with routing key {RoutingKey}",
                    typeof(T).Name, routingKey);
                throw;
            }
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                try
                {
                    _channel?.Close();
                    _channel?.Dispose();
                    _connection?.Close();
                    _connection?.Dispose();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error disposing RabbitMQ connection");
                }
                finally
                {
                    _disposed = true;
                }
            }
        }
    }
}
