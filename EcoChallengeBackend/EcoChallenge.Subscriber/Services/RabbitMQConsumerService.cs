using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using RabbitMQ.Client.Events;
using RabbitMQ.Client;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Models.Messages;
using Newtonsoft.Json;
using RabbitMQ.Client.Exceptions;

namespace EcoChallenge.Subscriber.Services
{
    public class RabbitMQConsumerService : IRabbitMQConsumerService
    {
        private readonly IConnection _connection;
        private readonly IModel _channel;
        private readonly IEmailService _emailService;
        private readonly ILogger<RabbitMQConsumerService> _logger;
        private readonly string _exchangeName;
        private readonly List<string> _consumerTags = new();
        private bool _disposed = false;

        public RabbitMQConsumerService(
            IConfiguration configuration,
            IEmailService emailService,
            ILogger<RabbitMQConsumerService> logger)
        {
            _emailService = emailService;
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
                RequestedHeartbeat = TimeSpan.FromSeconds(60),

                // Add these for better reliability
                RequestedChannelMax = 0,
                RequestedFrameMax = 0,
                UseBackgroundThreadsForIO = true
            };

            _exchangeName = configuration["RabbitMQ:ExchangeName"] ?? "ecochallenge.notifications";

            try
            {
                _connection = factory.CreateConnection("EcoChallenge-Subscriber");
                _channel = _connection.CreateModel();

                // Ensure exchange exists
                _channel.ExchangeDeclare(
                    exchange: _exchangeName,
                    type: ExchangeType.Topic,
                    durable: true,
                    autoDelete: false
                );

                // Set QoS to process one message at a time
                _channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

                _logger.LogInformation("RabbitMQ consumer connection established successfully to {HostName}:{Port}", 
                    factory.HostName, factory.Port);
                _logger.LogInformation("Using exchange: {ExchangeName}, VirtualHost: {VirtualHost}", 
                    _exchangeName, factory.VirtualHost);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to establish RabbitMQ consumer connection to {HostName}:{Port}", 
                    factory.HostName, factory.Port);
                throw;
            }
        }

        public async Task StartConsumingAsync(CancellationToken cancellationToken)
        {
            try
            {
                _logger.LogInformation("Setting up consumers...");

                // Setup consumers for all queues with error handling
                try
                {
                    SetupRequestStatusConsumer();
                    _logger.LogInformation("Request status consumer setup completed");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to setup request status consumer");
                    throw;
                }

                try
                {
                    SetupProofStatusConsumer();
                    _logger.LogInformation("Proof status consumer setup completed");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to setup proof status consumer");
                    throw;
                }

                try
                {
                    SetupPasswordResetConsumer();
                    _logger.LogInformation("Password reset consumer setup completed");
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to setup password reset consumer");
                    throw;
                }

                _logger.LogInformation("Started consuming messages from RabbitMQ. Consumer tags: {ConsumerTags}",
                    string.Join(", ", _consumerTags));

                // Keep the service running
                while (!cancellationToken.IsCancellationRequested)
                {
                    await Task.Delay(5000, cancellationToken); // Check every 5 seconds

                    // Log periodic status
                    _logger.LogDebug("Consumer service is running. Active consumers: {Count}", _consumerTags.Count);
                }
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Message consumption cancelled");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error in message consumption");
                throw;
            }
        }

        private void SetupRequestStatusConsumer()
        {
            var queueName = "ecochallenge.request.status.changed";

            // Declare queue with proper settings
            _channel.QueueDeclare(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                  arguments: null
            );

            var requestRoutingKeys = new[] {
                "request.status.approved",
                "request.status.denied",
                "request.status.changed"
            };

            foreach (var routingKey in requestRoutingKeys)
            {
                _channel.QueueBind(
                    queue: queueName,
                    exchange: _exchangeName,
                    routingKey: routingKey
                );
                _logger.LogInformation("Bound queue {QueueName} to routing key: {RoutingKey}", queueName, routingKey);
            }

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += async (model, ea) =>
            {
                var deliveryTag = ea.DeliveryTag;
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                var routingKey = ea.RoutingKey;

                _logger.LogInformation("Received request status message with routing key: {RoutingKey}, DeliveryTag: {DeliveryTag}",
                    routingKey, deliveryTag);
                _logger.LogDebug("Message content: {Message}", message);

                try
                {
                    var requestStatusChanged = JsonConvert.DeserializeObject<RequestStatusChanged>(message);
                    if (requestStatusChanged != null)
                    {
                        _logger.LogInformation("Processing request status change for Request {RequestId}, User: {UserEmail}",
                            requestStatusChanged.RequestId, requestStatusChanged.UserEmail);

                        await _emailService.SendRequestStatusChangedEmailAsync(requestStatusChanged);

                        // Acknowledge the message
                        _channel.BasicAck(deliveryTag: deliveryTag, multiple: false);

                        _logger.LogInformation("Successfully processed and acknowledged request status message for Request {RequestId}",
                            requestStatusChanged.RequestId);
                    }
                    else
                    {
                        _logger.LogWarning("Failed to deserialize request status message - message was null");
                        _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                    }
                }
                catch (JsonException jsonEx)
                {
                    _logger.LogError(jsonEx, "JSON deserialization error for request status message: {Message}", message);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing request status message: {Message}", message);

                    var requeue = ShouldRequeue(ex);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: requeue);

                    if (requeue)
                    {
                        _logger.LogInformation("Message requeued for retry");
                    }
                    else
                    {
                        _logger.LogWarning("Message discarded due to non-recoverable error");
                    }
                }
            };

            var consumerTag = _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);
            _consumerTags.Add(consumerTag);

            _logger.LogInformation("Started consuming from queue {QueueName} with consumer tag: {ConsumerTag}",
                queueName, consumerTag);
        }

        private void SetupProofStatusConsumer()
        {
            var queueName = "ecochallenge.proof.status.changed";
            
            try
            {
                _logger.LogInformation("Setting up proof status consumer for queue: {QueueName}", queueName);

                // Simply declare the queue - this is idempotent and will create if not exists
                var queueDeclareOk = _channel.QueueDeclare(
                    queue: queueName,
                    durable: true,
                    exclusive: false,
                    autoDelete: false,
                    arguments: null  // Simplified - removed TTL for now
                );
                
                _logger.LogInformation("Successfully declared queue {QueueName}. Messages: {MessageCount}, Consumers: {ConsumerCount}", 
                    queueName, queueDeclareOk.MessageCount, queueDeclareOk.ConsumerCount);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to declare queue {QueueName}", queueName);
                throw;
            }

            var proofRoutingKeys = new[] {
        "proof.status.approved",
        "proof.status.denied",
        "proof.status.changed"
    };

            foreach (var routingKey in proofRoutingKeys)
            {
                _channel.QueueBind(
                    queue: queueName,
                    exchange: _exchangeName,
                    routingKey: routingKey
                );
                _logger.LogInformation("Bound queue {QueueName} to routing key: {RoutingKey}", queueName, routingKey);
            }

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += async (model, ea) =>
            {
                var deliveryTag = ea.DeliveryTag;
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                var routingKey = ea.RoutingKey;

                _logger.LogInformation("Received proof status message with routing key: {RoutingKey}, DeliveryTag: {DeliveryTag}",
                    routingKey, deliveryTag);
                _logger.LogDebug("Message content: {Message}", message);

                try
                {
                    var proofStatusChanged = JsonConvert.DeserializeObject<ProofStatusChanged>(message);
                    if (proofStatusChanged != null)
                    {
                        _logger.LogInformation("Processing proof status change for Participation {ParticipationId}, User: {UserEmail}",
                            proofStatusChanged.ParticipationId, proofStatusChanged.UserEmail);

                        await _emailService.SendProofStatusChangedEmailAsync(proofStatusChanged);

                        // Acknowledge the message
                        _channel.BasicAck(deliveryTag: deliveryTag, multiple: false);

                        _logger.LogInformation("Successfully processed and acknowledged proof status message for Participation {ParticipationId}",
                            proofStatusChanged.ParticipationId);
                    }
                    else
                    {
                        _logger.LogWarning("Failed to deserialize proof status message - message was null");
                        _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                    }
                }
                catch (JsonException jsonEx)
                {
                    _logger.LogError(jsonEx, "JSON deserialization error for proof status message: {Message}", message);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing proof status message: {Message}", message);

                    var requeue = ShouldRequeue(ex);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: requeue);

                    if (requeue)
                    {
                        _logger.LogInformation("Message requeued for retry");
                    }
                    else
                    {
                        _logger.LogWarning("Message discarded due to non-recoverable error");
                    }
                }
            };

            var consumerTag = _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);
            _consumerTags.Add(consumerTag);

            _logger.LogInformation("Started consuming from queue {QueueName} with consumer tag: {ConsumerTag}",
                queueName, consumerTag);
        }
        private void SetupPasswordResetConsumer()
        {
            var queueName = "ecochallenge.password.reset.requested";

            // Declare queue
            _channel.QueueDeclare(
                queue: queueName,
                durable: true,
                exclusive: false,
                autoDelete: false,
                arguments: null
            );

            // Bind to routing key
            _channel.QueueBind(
                queue: queueName,
                exchange: _exchangeName,
                routingKey: "password.reset.requested"
            );

            _logger.LogInformation("Bound queue {QueueName} to routing key: password.reset.requested", queueName);

            var consumer = new EventingBasicConsumer(_channel);
            consumer.Received += async (model, ea) =>
            {
                var deliveryTag = ea.DeliveryTag;
                var body = ea.Body.ToArray();
                var message = Encoding.UTF8.GetString(body);
                var routingKey = ea.RoutingKey;

                _logger.LogInformation("Received password reset message with routing key: {RoutingKey}, DeliveryTag: {DeliveryTag}",
                    routingKey, deliveryTag);
                _logger.LogDebug("Message content: {Message}", message);

                try
                {
                    var passwordResetRequested = JsonConvert.DeserializeObject<PasswordResetRequested>(message);
                    if (passwordResetRequested != null)
                    {
                        _logger.LogInformation("Processing password reset for User {UserId}, Email: {UserEmail}",
                            passwordResetRequested.UserId, passwordResetRequested.UserEmail);

                        await _emailService.SendPasswordResetEmailAsync(passwordResetRequested);

                        // Acknowledge the message
                        _channel.BasicAck(deliveryTag: deliveryTag, multiple: false);

                        _logger.LogInformation("Successfully processed and acknowledged password reset message for User {UserId}",
                            passwordResetRequested.UserId);
                    }
                    else
                    {
                        _logger.LogWarning("Failed to deserialize password reset message - message was null");
                        _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                    }
                }
                catch (JsonException jsonEx)
                {
                    _logger.LogError(jsonEx, "JSON deserialization error for password reset message: {Message}", message);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: false);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error processing password reset message: {Message}", message);

                    var requeue = ShouldRequeue(ex);
                    _channel.BasicNack(deliveryTag: deliveryTag, multiple: false, requeue: requeue);

                    if (requeue)
                    {
                        _logger.LogInformation("Message requeued for retry");
                    }
                    else
                    {
                        _logger.LogWarning("Message discarded due to non-recoverable error");
                    }
                }
            };

            var consumerTag = _channel.BasicConsume(queue: queueName, autoAck: false, consumer: consumer);
            _consumerTags.Add(consumerTag);

            _logger.LogInformation("Started consuming from queue {QueueName} with consumer tag: {ConsumerTag}",
                queueName, consumerTag);
        }
        private bool ShouldRequeue(Exception ex)
        {
            // Don't requeue for certain types of exceptions
            return ex switch
            {
                JsonException => false,           // Bad message format
                ArgumentException => false,       // Invalid data
                FormatException => false,         // Invalid data format
                _ => true                        // Requeue for transient errors (network, SMTP, etc.)
            };
        }

        public async Task StopConsumingAsync()
        {
            try
            {
                // Cancel all consumers
                foreach (var consumerTag in _consumerTags)
                {
                    try
                    {
                        _channel?.BasicCancel(consumerTag);
                        _logger.LogInformation("Cancelled consumer: {ConsumerTag}", consumerTag);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogWarning(ex, "Error cancelling consumer {ConsumerTag}", consumerTag);
                    }
                }

                _consumerTags.Clear();

                _channel?.Close();
                _connection?.Close();
                _logger.LogInformation("Stopped consuming messages from RabbitMQ");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error stopping RabbitMQ consumer");
            }

            await Task.CompletedTask;
        }

        public void Dispose()
        {
            if (!_disposed)
            {
                try
                {
                    // First cancel all consumers
                    foreach (var consumerTag in _consumerTags)
                    {
                        try
                        {
                            _channel?.BasicCancelNoWait(consumerTag);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogWarning(ex, "Error cancelling consumer {ConsumerTag}", consumerTag);
                        }
                    }
                    _consumerTags.Clear();

                    // Close channel if open
                    if (_channel?.IsOpen == true)
                    {
                        _channel.Close();
                    }

                    // Close connection if open
                    if (_connection?.IsOpen == true)
                    {
                        _connection.Close();
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error disposing RabbitMQ consumer");
                }
                finally
                {
                    _channel?.Dispose();
                    _connection?.Dispose();
                    _disposed = true;
                }
            }
        }
    }
}
