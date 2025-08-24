using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using EcoChallenge.WebAPI.BaseControllers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class BadgeController : BaseCRUDController<BadgeResponse, BadgeSearchObject, BadgeInsertRequest, BadgeUpdateRequest>
    {
        private readonly IBadgeManagementService _badgeManagementService;
        private readonly IUserBadgeService _userBadgeService;
        private readonly ILogger<BadgeController> _logger;
        private readonly EcoChallengeDbContext _context;
        public BadgeController(
            IBadgeService service,
            IBadgeManagementService badgeManagementService,
            IUserBadgeService userBadgeService,
            ILogger<BadgeController> logger,
            EcoChallengeDbContext context) : base(service)
        {
            _badgeManagementService = badgeManagementService;
            _userBadgeService = userBadgeService;
            _logger = logger;
            _context = context;
        }

        [HttpPost]
        [Consumes("multipart/form-data")]
        public override async Task<BadgeResponse> Create([FromForm] BadgeInsertRequest request)
        {
            return await _crudService.CreateAsync(request);
        }

        [HttpPut("{id}")]
        [Consumes("multipart/form-data")]
        public override async Task<BadgeResponse?> Update(int id, [FromForm] BadgeUpdateRequest request)
        {
            return await _crudService.UpdateAsync(id, request);
        }

        // NEW METHODS FOR BADGE MANAGEMENT:

        [HttpGet("user/{userId}")]
        public async Task<ActionResult<List<UserBadge>>> GetUserBadges(int userId)
        {
            try
            {
                var badges = await _badgeManagementService.GetUserBadgesAsync(userId);
                return Ok(badges);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving badges for user {UserId}", userId);
                return StatusCode(500, "An error occurred while retrieving user badges");
            }
        }

        [HttpPost("check/{userId}")]
        [Authorize] // Add authorization as needed
        public async Task<ActionResult> CheckUserBadges(int userId)
        {
            try
            {
                await _badgeManagementService.CheckAndAwardBadgesAsync(userId);
                return Ok(new { message = "Badge check completed successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking badges for user {UserId}", userId);
                return StatusCode(500, "An error occurred while checking badges");
            }
        }

        [HttpPost("initialize")]
        [Authorize(Roles = "Admin")] // Admin only
        public async Task<ActionResult> InitializeDefaultBadges()
        {
            try
            {
                await _badgeManagementService.InitializeDefaultBadgesAsync();
                return Ok(new { message = "Default badges initialized successfully" });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error initializing default badges");
                return StatusCode(500, "An error occurred while initializing badges");
            }
        }

        [HttpPost("{id}/award/{userId}")]
        [Authorize(Roles = "Admin")] // Admin only - manual badge awarding
        public async Task<ActionResult> AwardBadge(int id, int userId, [FromBody] string reason = "Manually awarded by admin")
        {
            try
            {
                var search = new UserBadgeSearchObject { UserId = userId, BadgeId = id };
                var existingBadge = await _userBadgeService.GetAsync(search);

                if (existingBadge.Items.Any())
                {
                    return BadRequest("User already has this badge");
                }

                var request = new UserBadgeInsertRequest
                {
                    UserId = userId,
                    BadgeId = id,
                    EarnedAt = DateTime.UtcNow
                };

                var result = await _userBadgeService.CreateAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error awarding badge {BadgeId} to user {UserId}", id, userId);
                return StatusCode(500, "An error occurred while awarding the badge");
            }
        }

        [HttpGet("statistics")]
        [Authorize(Roles = "Admin")]
        public async Task<ActionResult> GetBadgeStatistics()
        {
            try
            {
                // Get badge distribution statistics
                var statistics = new
                {
                    TotalBadges = await _crudService.GetAsync(new BadgeSearchObject { RetrieveAll = true }),
                    MostEarnedBadges = "You can implement this query",
                    RecentlyAwarded = "You can implement this query"
                };

                return Ok(statistics);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retrieving badge statistics");
                return StatusCode(500, "An error occurred while retrieving statistics");
            }
        }


    }
}
