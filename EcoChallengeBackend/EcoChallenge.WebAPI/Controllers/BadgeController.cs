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

        [HttpPost("seed-badges")]
        public async Task<IActionResult> SeedBadges()
        {
            await using var transaction = await _context.Database.BeginTransactionAsync();

            try
            {
                // Enable identity insert
                await _context.Database.ExecuteSqlRawAsync("SET IDENTITY_INSERT [Badges] ON");
                // Check if badges already exist
                var existingBadges = await _context.Badges.ToListAsync();


                // Add all badges including those with IDs 1 and 2
                var badges = new[]
                {

                new Badge
                {
                    Id = 3,
                    Name = "Eco Warrior",
                    Description = "Reached 1000 points",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 2, // Points
                    CriteriaValue = 1000,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 4,
                    Name = "Environmental Champion",
                    Description = "Earned 2500 points",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 2, // Points
                    CriteriaValue = 2500,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 5,
                    Name = "Green Legend",
                    Description = "Accumulated 5000 points",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 2, // Points
                    CriteriaValue = 5000,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 6,
                    Name = "First Cleanup",
                    Description = "Completed your first cleanup activity",
                    BadgeTypeId = 3, // Milestone
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 7,
                    Name = "Getting Active",
                    Description = "Completed 3 cleanup activities",
                    BadgeTypeId = 1, // Participation
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 3,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 8,
                    Name = "Active Member",
                    Description = "Completed 5 cleanup activities",
                    BadgeTypeId = 1, // Participation
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 5,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 9,
                    Name = "Dedicated Volunteer",
                    Description = "Completed 10 cleanup activities",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 10,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 10,
                    Name = "Super Volunteer",
                    Description = "Completed 25 cleanup activities",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 25,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 11,
                    Name = "Cleanup Master",
                    Description = "Completed 50 cleanup activities",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 50,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 12,
                    Name = "Event Organizer",
                    Description = "Organized your first community event",
                    BadgeTypeId = 3, // Milestone
                    CriteriaTypeId = 3, // EventsOrganized
                    CriteriaValue = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 13,
                    Name = "Community Builder",
                    Description = "Organized 3 community events",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 3, // EventsOrganized
                    CriteriaValue = 3,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 14,
                    Name = "Community Leader",
                    Description = "Organized 5 community events",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 3, // EventsOrganized
                    CriteriaValue = 5,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 15,
                    Name = "Event Master",
                    Description = "Organized 10 community events",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 3, // EventsOrganized
                    CriteriaValue = 10,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 16,
                    Name = "First Participant",
                    Description = "Attended your first event",
                    BadgeTypeId = 3, // Milestone
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 17,
                    Name = "Team Player",
                    Description = "Participated in 3 events",
                    BadgeTypeId = 1, // Participation
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 3,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 18,
                    Name = "Regular Participant",
                    Description = "Participated in 10 events",
                    BadgeTypeId = 1, // Participation
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 10,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 19,
                    Name = "Event Enthusiast",
                    Description = "Participated in 20 events",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 20,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 20,
                    Name = "Early Adopter",
                    Description = "One of the first users to join the platform",
                    BadgeTypeId = 4, // Special
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 21,
                    Name = "Consistent Contributor",
                    Description = "Active for 30 consecutive days",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 5, // Days (if you have this criteria)
                    CriteriaValue = 30,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 22,
                    Name = "Donation Star",
                    Description = "Made your first donation",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 4, // Donations (if you have this criteria)
                    CriteriaValue = 1,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 23,
                    Name = "Generous Donor",
                    Description = "Made 5 donations",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 4, // Donations
                    CriteriaValue = 5,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 24,
                    Name = "Community Helper",
                    Description = "Helped 10 different cleanup requests",
                    BadgeTypeId = 2, // Achievement
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 10,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                },
                new Badge
                {
                    Id = 25,
                    Name = "Weekend Warrior",
                    Description = "Completed 5 weekend activities",
                    BadgeTypeId = 1, // Participation
                    CriteriaTypeId = 1, // Count
                    CriteriaValue = 5,
                    IsActive = true,
                    CreatedAt = new DateTime(2025, 1, 1)
                }
            };

                await _context.Badges.AddRangeAsync(badges);
                await _context.SaveChangesAsync();

                await _context.Database.ExecuteSqlRawAsync("SET IDENTITY_INSERT [Badges] OFF");
                await transaction.CommitAsync();

                return Ok(new { Message = "Badges seeded successfully", Count = badges.Length });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { Message = "Error seeding badges", Error = ex.Message });
            }
        }
    }
}
