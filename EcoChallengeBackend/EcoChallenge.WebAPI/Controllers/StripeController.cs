using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Services.Interfeces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class StripeController : ControllerBase
    {
        private readonly IStripeService _stripeService;
        private readonly ILogger<StripeController> _logger;

        public StripeController(IStripeService stripeService, ILogger<StripeController> logger)
        {
            _stripeService = stripeService;
            _logger = logger;
        }

        [HttpPost("create-payment-intent")]
        public async Task<ActionResult<StripePaymentResponse>> CreatePaymentIntent([FromBody] StripePaymentRequest request)
        {
            try
            {
                var result = await _stripeService.CreatePaymentIntentAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error creating payment intent");
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("confirm-payment/{paymentIntentId}")]
        public async Task<ActionResult<StripePaymentResponse>> ConfirmPayment(string paymentIntentId)
        {
            try
            {
                var result = await _stripeService.ConfirmPaymentAsync(paymentIntentId);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error confirming payment");
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("webhook")]
        [AllowAnonymous]
        public async Task<IActionResult> HandleWebhook()
        {
            try
            {
                var payload = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();
                var signature = Request.Headers["Stripe-Signature"].FirstOrDefault();

                if (string.IsNullOrEmpty(signature))
                {
                    return BadRequest("Missing Stripe signature");
                }

                var success = await _stripeService.HandleWebhookAsync(payload, signature);
                return success ? Ok() : BadRequest();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Webhook handling failed");
                return StatusCode(500);
            }
        }

        [HttpGet("config")]
        public async Task<ActionResult<StripeConfigResponse>> GetConfig()
        {
            try
            {
                var config = await _stripeService.GetConfigAsync();
                return Ok(config);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error getting Stripe config");
                return BadRequest(new { error = ex.Message });
            }
        }
    }
}
