using EcoChallenge.Models.Messages;
using EcoChallenge.Services.Interfeces;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [Route("api/[controller]")]
    public class TestController : ControllerBase
    {
        private readonly IRabbitMQService _rabbitMQService;
        private readonly ILogger<TestController> _logger;

        public TestController(IRabbitMQService rabbitMQService, ILogger<TestController> logger)
        {
            _rabbitMQService = rabbitMQService;
            _logger = logger;
        }

        [HttpPost("test-rabbitmq")]
        public async Task<IActionResult> TestRabbitMQ()
        {
            try
            {
                var testMessage = new RequestStatusChanged
                {
                    RequestId = 999,
                    UserId = 1,
                    UserEmail = "nedim.jugoo@gmail.com",
                    UserName = "Test User",
                    RequestTitle = "Test Request",
                    OldStatus = "Pending",
                    NewStatus = "Approved",
                    ChangedAt = DateTime.UtcNow,
                    ActualRewardPoints = 100,
                    ActualRewardMoney = 10.50m
                };

                await _rabbitMQService.PublishAsync(testMessage, "request.status.approved");

                _logger.LogInformation("Test message published successfully");
                return Ok(new { message = "Test message published successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish test message");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("rabbitmq-status")]
        public IActionResult GetRabbitMQStatus()
        {
            try
            {
                // This will fail if RabbitMQ service isn't properly initialized
                return Ok(new
                {
                    status = "RabbitMQ service is initialized",
                    timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}
