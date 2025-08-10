using EcoChallenge.Models.Requests;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AdminAuthController : ControllerBase
    {
        private readonly IAdminAuthService _adminAuthService;
        private readonly ILogger<AdminAuthController> _logger;
        private readonly IRequestService _requestService;
        private readonly IMLPricingService _mlPricingService;

        public AdminAuthController(IAdminAuthService adminAuthService, ILogger<AdminAuthController> logger, IRequestService requestService, IMLPricingService mlPricingService)
        {
            _adminAuthService = adminAuthService;
            _logger = logger;
            _requestService = requestService;
            _mlPricingService = mlPricingService;
        }

        [HttpPost("retrain-ml-model")]
        public async Task<IActionResult> RetrainMLModel()
        {
            try
            {
                await _mlPricingService.TrainModelAsync();
                return Ok(new { message = "ML model retrained successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpPost("reanalyze-request/{id}")]
        public async Task<IActionResult> ReanalyzeRequest(int id)
        {
            try
            {
                await _requestService.ReanalyzeRequestAsync(id);
                return Ok(new { message = "Request reanalyzed successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        [HttpGet("ml-model-status")]
        public async Task<IActionResult> GetMLModelStatus()
        {
            var isModelTrained = await _mlPricingService.IsModelTrainedAsync();
            return Ok(new { isModelTrained });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login([FromBody] UserLoginRequest request, CancellationToken cancellationToken = default)
        {
            try
            {
                if (!ModelState.IsValid)
                {
                    return BadRequest(new { message = "Invalid request data", errors = ModelState });
                }

                var result = await _adminAuthService.AuthenticateAdminAsync(request, cancellationToken);

                if (result == null)
                {
                    return Unauthorized(new { message = "Invalid credentials or insufficient admin privileges" });
                }

                // Create Basic Auth credentials for the response
                var credentials = Convert.ToBase64String(
                    System.Text.Encoding.UTF8.GetBytes($"{request.Username}:{request.Password}"));

                return Ok(new
                {
                    message = "Admin login successful",
                    data = result,
                    basicAuthCredentials = credentials // Client will use this for subsequent requests
                });
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Admin login request was cancelled");
                return StatusCode(499, new { message = "Request was cancelled" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during admin login");
                return StatusCode(500, new { message = "An error occurred during login" });
            }
        }

        [HttpGet("profile")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> GetProfile(CancellationToken cancellationToken = default)
        {
            try
            {
                var username = User.FindFirst(ClaimTypes.Name)?.Value;

                if (string.IsNullOrEmpty(username))
                {
                    return Unauthorized(new { message = "Unable to identify user" });
                }

                var profile = await _adminAuthService.GetAdminProfileAsync(username, cancellationToken);

                if (profile == null)
                {
                    return NotFound(new { message = "Admin profile not found" });
                }

                return Ok(new
                {
                    message = "Profile retrieved successfully",
                    data = profile
                });
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Get profile request was cancelled");
                return StatusCode(499, new { message = "Request was cancelled" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving admin profile");
                return StatusCode(500, new { message = "An error occurred while retrieving profile" });
            }
        }

        [HttpPost("validate")]
        [Authorize(Roles = "Admin")]
        public async Task<IActionResult> ValidateAdmin(CancellationToken cancellationToken = default)
        {
            try
            {
                var username = User.FindFirst(ClaimTypes.Name)?.Value;
                var userType = User.FindFirst(ClaimTypes.Role)?.Value;

                if (string.IsNullOrEmpty(username))
                {
                    return Unauthorized(new { message = "Unable to identify user" });
                }

                var isAdmin = await _adminAuthService.IsUserAdminAsync(username, cancellationToken);

                if (!isAdmin)
                {
                    return Unauthorized(new { message = "User does not have admin privileges" });
                }

                return Ok(new
                {
                    message = "Admin validation successful",
                    data = new
                    {
                        username = username,
                        userType = userType,
                        isAdmin = true,
                        validatedAt = DateTime.UtcNow
                    }
                });
            }
            catch (OperationCanceledException)
            {
                _logger.LogInformation("Admin validation request was cancelled");
                return StatusCode(499, new { message = "Request was cancelled" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error validating admin");
                return StatusCode(500, new { message = "An error occurred during validation" });
            }
        }

        [HttpPost("logout")]
        [Authorize(Roles = "Admin")]
        public IActionResult Logout()
        {
            try
            {
                var username = User.FindFirst(ClaimTypes.Name)?.Value;
                _logger.LogInformation("Admin logout for username: {Username}", username);

                // In Basic Auth, logout is typically handled client-side by clearing credentials
                return Ok(new { message = "Logout successful" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error during admin logout");
                return StatusCode(500, new { message = "An error occurred during logout" });
            }
        }
    }
}
