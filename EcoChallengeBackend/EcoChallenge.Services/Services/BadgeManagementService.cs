using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using EcoChallenge.Models.Responses;

namespace EcoChallenge.Services.Services
{
    public class BadgeManagementService : IBadgeManagementService
    {
        private readonly EcoChallengeDbContext _context;
        private readonly ILogger<BadgeManagementService> _logger;
        private readonly INotificationService _notificationService;

        public BadgeManagementService(
            EcoChallengeDbContext context,
            ILogger<BadgeManagementService> logger,
            INotificationService notificationService)
        {
            _context = context;
            _logger = logger;
            _notificationService = notificationService;
        }

        public async Task CheckAndAwardBadgesAsync(int userId)
        {
            try
            {
                _logger.LogInformation("Starting badge check for user {UserId}", userId);

                await CheckPointsBadgesAsync(userId);
                await CheckRequestsBadgesAsync(userId);
                await CheckEventsBadgesAsync(userId);
                await CheckParticipationBadgesAsync(userId);
                await CheckDonationBadgesAsync(userId);

                _logger.LogInformation("Badge check completed for user {UserId}", userId);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error checking badges for user {UserId}", userId);
                throw;
            }
        }

        public async Task CheckPointsBadgesAsync(int userId)
        {
            // Get user's total points from EventParticipant and RequestParticipation
            var userPoints = await CalculateUserPointsAsync(userId);

            var pointsBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "Points" && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in pointsBadges)
            {
                if (userPoints >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id, $"Earned {userPoints} points");
                }
            }
        }

        public async Task CheckRequestsBadgesAsync(int userId)
        {
            // Count user's submitted requests
            var requestCount = await _context.Requests
                .CountAsync(r => r.UserId == userId);

            // Count approved request participations
            var approvedParticipations = await _context.RequestParticipations
                .CountAsync(rp => rp.UserId == userId && rp.Status == Models.Enums.ParticipationStatus.Approved);

            var countBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "Count" && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in countBadges)
            {
                var totalActivity = requestCount + approvedParticipations;
                if (totalActivity >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id,
                        $"Completed {totalActivity} cleanup activities ({requestCount} requests, {approvedParticipations} participations)");
                }
            }
        }

        public async Task CheckEventsBadgesAsync(int userId)
        {
            // Count events organized by user
            var eventsOrganized = await _context.Events
                .CountAsync(e => e.CreatorUserId == userId);

            // Count events participated in
            var eventsParticipated = await _context.EventParticipants
                .CountAsync(ep => ep.UserId == userId && ep.Status == Models.Enums.AttendanceStatus.Attended);

            var eventBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "EventsOrganized" && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in eventBadges)
            {
                if (eventsOrganized >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id, $"Organized {eventsOrganized} events");
                }
            }

            // Check participation badges (using Count criteria type for participation)
            var participationBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "Count" &&
                           b.Name.ToLower().Contains("participant") && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in participationBadges)
            {
                if (eventsParticipated >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id, $"Participated in {eventsParticipated} events");
                }
            }
        }

        public async Task CheckParticipationBadgesAsync(int userId)
        {
            // Count total participations across all activities
            var totalParticipations = await _context.RequestParticipations
                .CountAsync(rp => rp.UserId == userId && rp.Status == Models.Enums.ParticipationStatus.Approved) +
                await _context.EventParticipants
                .CountAsync(ep => ep.UserId == userId && ep.Status == Models.Enums.AttendanceStatus.Attended);

            var participationBadges = await _context.Badges
                .Where(b => (b.CriteriaType.Name == "Count" || b.CriteriaType.Name == "Participation") &&
                           b.Name.ToLower().Contains("participation") && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in participationBadges)
            {
                if (totalParticipations >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id, $"Total participations: {totalParticipations}");
                }
            }
        }

        public async Task CheckDonationBadgesAsync(int userId)
        {
            // Get user's total donations amount and count
            var donationStats = await _context.Donations
                .Where(d => d.UserId == userId && d.StatusId == 2) // Completed donations
                .GroupBy(d => 1)
                .Select(g => new
                {
                    TotalAmount = g.Sum(d => d.Amount),
                    TotalCount = g.Count()
                })
                .FirstOrDefaultAsync();

            var totalAmount = donationStats?.TotalAmount ?? 0;
            var totalCount = donationStats?.TotalCount ?? 0;

            // Check amount-based badges (using Special criteria type for amount)
            var amountBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "Special" &&
                           b.Name.ToLower().Contains("donation") &&
                           b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in amountBadges)
            {
                if (totalAmount >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id,
                        $"Donated {totalAmount} BAM in total");
                }
            }

            // Check count-based badges (using DonationsMade criteria type)
            var countBadges = await _context.Badges
                .Where(b => b.CriteriaType.Name == "DonationsMade" && b.IsActive)
                .OrderBy(b => b.CriteriaValue)
                .ToListAsync();

            foreach (var badge in countBadges)
            {
                if (totalCount >= badge.CriteriaValue)
                {
                    await AwardBadgeIfNotEarnedAsync(userId, badge.Id,
                        $"Made {totalCount} donations");
                }
            }
        }

        public async Task<List<UserBadgeResponse>> GetUserBadgesAsync(int userId)
        {
            var userBadges = await _context.UserBadges
                .Include(ub => ub.Badge)
                    .ThenInclude(b => b.BadgeType)
                .Include(ub => ub.Badge)
                    .ThenInclude(b => b.CriteriaType)
                .Where(ub => ub.UserId == userId)
                .OrderByDescending(ub => ub.EarnedAt)
                .Select(ub => new UserBadgeResponse
                {
                    Id = ub.Id,
                    UserId = ub.UserId,
                    BadgeId = ub.BadgeId,
                    EarnedAt = ub.EarnedAt,
                    Badge = new BadgeResponse
                    {
                        Id = ub.Badge.Id,
                        Name = ub.Badge.Name,
                        Description = ub.Badge.Description,
                        IconUrl = ub.Badge.IconUrl,
                        BadgeTypeId = ub.Badge.BadgeTypeId,
                        CriteriaTypeId = ub.Badge.CriteriaTypeId,
                        CriteriaValue = ub.Badge.CriteriaValue,
                        IsActive = ub.Badge.IsActive,
                        CreatedAt = ub.Badge.CreatedAt,
                        BadgeType = new BadgeTypeResponse
                        {
                            Id = ub.Badge.BadgeType.Id,
                            Name = ub.Badge.BadgeType.Name
                        },
                        CriteriaType = new CriteriaTypeResponse
                        {
                            Id = ub.Badge.CriteriaType.Id,
                            Name = ub.Badge.CriteriaType.Name
                        }
                    }
                })
                .ToListAsync();

            return userBadges;
        }

        private async Task<int> CalculateUserPointsAsync(int userId)
        {
            var eventPoints = await _context.EventParticipants
                .Where(ep => ep.UserId == userId)
                .SumAsync(ep => ep.PointsEarned);

            var requestPoints = await _context.RequestParticipations
                .Where(rp => rp.UserId == userId && rp.Status == Models.Enums.ParticipationStatus.Approved)
                .SumAsync(rp => rp.RewardPoints);

            var donationPoints = await _context.Donations
        .Where(d => d.UserId == userId && d.StatusId == 2) // Completed donations
        .SumAsync(d => d.PointsEarned);

            return eventPoints + requestPoints;
        }

        private async Task AwardBadgeIfNotEarnedAsync(int userId, int badgeId, string reason = "")
        {
            // Check if user already has this badge
            var existingBadge = await _context.UserBadges
                .FirstOrDefaultAsync(ub => ub.UserId == userId && ub.BadgeId == badgeId);

            if (existingBadge != null)
                return; // Badge already earned

            // Award the badge
            var userBadge = new UserBadge
            {
                UserId = userId,
                BadgeId = badgeId,
                EarnedAt = DateTime.UtcNow
            };

            _context.UserBadges.Add(userBadge);
            await _context.SaveChangesAsync();

            // Get badge details for notification
            var badge = await _context.Badges
                .Include(b => b.BadgeType)
                .FirstOrDefaultAsync(b => b.Id == badgeId);

            if (badge != null)
            {
                _logger.LogInformation("Badge '{BadgeName}' awarded to user {UserId}. Reason: {Reason}",
                    badge.Name, userId, reason);

                // Send notification to user
                await SendBadgeNotificationAsync(userId, badge, reason);
            }
        }

        private async Task SendBadgeNotificationAsync(int userId, Badge badge, string reason)
        {
            try
            {
                var notificationRequest = new Models.Requests.NotificationInsertRequest
                {
                    UserId = userId,
                    NotificationType = Models.Enums.NotificationType.BadgeEarned,
                    Title = "🏆 New Badge Earned!",
                    Message = $"Congratulations! You've earned the '{badge.Name}' badge. {badge.Description}",
                    IsPushed = false
                };

                await _notificationService.CreateAsync(notificationRequest);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to send badge notification for badge {BadgeId} to user {UserId}",
                    badge.Id, userId);
            }
        }

        public async Task InitializeDefaultBadgesAsync()
        {
            try
            {
                // Check if badges already exist
                var existingBadgesCount = await _context.Badges.CountAsync();
                if (existingBadgesCount > 0)
                {
                    _logger.LogInformation("Default badges already exist. Skipping initialization.");
                    return;
                }

                var defaultBadges = new List<Badge>
                {
                    // Points-based badges
                    new Badge
                    {
                        Name = "First Steps",
                        Description = "Earned your first 100 points",
                        BadgeTypeId = 3, // Milestone
                        CriteriaTypeId = 2, // Points
                        CriteriaValue = 100,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Point Collector",
                        Description = "Accumulated 500 points",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 2, // Points
                        CriteriaValue = 500,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Eco Warrior",
                        Description = "Reached 1000 points",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 2, // Points
                        CriteriaValue = 1000,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Environmental Champion",
                        Description = "Earned 2500 points",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 2, // Points
                        CriteriaValue = 2500,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },

                    // Activity count badges
                    new Badge
                    {
                        Name = "Getting Started",
                        Description = "Completed your first cleanup activity",
                        BadgeTypeId = 3, // Milestone
                        CriteriaTypeId = 1, // Count
                        CriteriaValue = 1,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Active Member",
                        Description = "Completed 5 cleanup activities",
                        BadgeTypeId = 1, // Participation
                        CriteriaTypeId = 1, // Count
                        CriteriaValue = 5,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Dedicated Volunteer",
                        Description = "Completed 10 cleanup activities",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 1, // Count
                        CriteriaValue = 10,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Super Volunteer",
                        Description = "Completed 25 cleanup activities",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 1, // Count
                        CriteriaValue = 25,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },

                    // Event organization badges
                    new Badge
                    {
                        Name = "Event Organizer",
                        Description = "Organized your first community event",
                        BadgeTypeId = 3, // Milestone
                        CriteriaTypeId = 3, // EventsOrganized
                        CriteriaValue = 1,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Community Leader",
                        Description = "Organized 3 community events",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 3, // EventsOrganized
                        CriteriaValue = 3,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Event Master",
                        Description = "Organized 10 community events",
                        BadgeTypeId = 2, // Achievement
                        CriteriaTypeId = 3, // EventsOrganized
                        CriteriaValue = 10,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },

                    // Participation badges
                    new Badge
                    {
                        Name = "Team Player",
                        Description = "Participated in 3 events",
                        BadgeTypeId = 1, // Participation
                        CriteriaTypeId = 1, // Count (for participation)
                        CriteriaValue = 3,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    },
                    new Badge
                    {
                        Name = "Regular Participant",
                        Description = "Participated in 10 events",
                        BadgeTypeId = 1, // Participation
                        CriteriaTypeId = 1, // Count (for participation)
                        CriteriaValue = 10,
                        IsActive = true,
                        CreatedAt = DateTime.UtcNow
                    }
                };

                _context.Badges.AddRange(defaultBadges);
                await _context.SaveChangesAsync();

                _logger.LogInformation("Successfully initialized {Count} default badges", defaultBadges.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error initializing default badges");
                throw;
            }
        }
    }
}
