using EcoChallenge.Models.Enums;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class UserStatsService : IUserStatsService
    {
        private readonly EcoChallengeDbContext _context;
        private readonly ILogger<UserStatsService> _logger;

        public UserStatsService(EcoChallengeDbContext context, ILogger<UserStatsService> logger)
        {
            _context = context;
            _logger = logger;
        }

        public async Task UpdateUserPointsAsync(int userId, int points, CancellationToken cancellationToken = default)
        {
            try
            {
                var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);
                if (user != null)
                {
                    user.TotalPoints += points;
                    user.UpdatedAt = DateTime.UtcNow;

                    _context.Users.Update(user);
                    await _context.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation("Updated points for user {UserId}: added {Points} points, total now {TotalPoints}",
                        userId, points, user.TotalPoints);
                }
                else
                {
                    _logger.LogWarning("User {UserId} not found when trying to update points", userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to update points for user {UserId}", userId);
                throw;
            }
        }

        public async Task UpdateUserCleanupsAsync(int userId, int increment, CancellationToken cancellationToken = default)
        {
            try
            {
                var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);
                if (user != null)
                {
                    user.TotalCleanups += increment;
                    user.UpdatedAt = DateTime.UtcNow;

                    _context.Users.Update(user);
                    await _context.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation("Updated cleanups for user {UserId}: added {Increment}, total now {TotalCleanups}",
                        userId, increment, user.TotalCleanups);
                }
                else
                {
                    _logger.LogWarning("User {UserId} not found when trying to update cleanups", userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to update cleanups for user {UserId}", userId);
                throw;
            }
        }

        public async Task UpdateUserEventsOrganizedAsync(int userId, int increment, CancellationToken cancellationToken = default)
        {
            try
            {
                var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);
                if (user != null)
                {
                    user.TotalEventsOrganized += increment;
                    user.UpdatedAt = DateTime.UtcNow;

                    _context.Users.Update(user);
                    await _context.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation("Updated events organized for user {UserId}: added {Increment}, total now {TotalEventsOrganized}",
                        userId, increment, user.TotalEventsOrganized);
                }
                else
                {
                    _logger.LogWarning("User {UserId} not found when trying to update events organized", userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to update events organized for user {UserId}", userId);
                throw;
            }
        }

        public async Task UpdateUserEventsParticipatedAsync(int userId, int increment, CancellationToken cancellationToken = default)
        {
            try
            {
                var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);
                if (user != null)
                {
                    user.TotalEventsParticipated += increment;
                    user.UpdatedAt = DateTime.UtcNow;

                    _context.Users.Update(user);
                    await _context.SaveChangesAsync(cancellationToken);

                    _logger.LogInformation("Updated events participated for user {UserId}: added {Increment}, total now {TotalEventsParticipated}",
                        userId, increment, user.TotalEventsParticipated);
                }
                else
                {
                    _logger.LogWarning("User {UserId} not found when trying to update events participated", userId);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to update events participated for user {UserId}", userId);
                throw;
            }
        }

        public async Task RecalculateUserStatsAsync(int userId, CancellationToken cancellationToken = default)
        {
            try
            {
                var user = await _context.Users.FindAsync(new object[] { userId }, cancellationToken);
                if (user == null)
                {
                    _logger.LogWarning("User {UserId} not found when trying to recalculate stats", userId);
                    return;
                }

                // Recalculate total points from approved request participations
                var totalPoints = await _context.RequestParticipations
                    .Where(rp => rp.UserId == userId && rp.Status == ParticipationStatus.Approved)
                    .SumAsync(rp => rp.RewardPoints, cancellationToken);

                // Recalculate total cleanups from approved request participations
                var totalCleanups = await _context.RequestParticipations
                    .Where(rp => rp.UserId == userId && rp.Status == ParticipationStatus.Approved)
                    .CountAsync(cancellationToken);

                // Recalculate total events organized
                var totalEventsOrganized = await _context.Events
                    .Where(e => e.CreatorUserId == userId)
                    .CountAsync(cancellationToken);

                // Recalculate total events participated (attended events)
                var totalEventsParticipated = await _context.EventParticipants
                    .Where(ep => ep.UserId == userId && ep.Status == AttendanceStatus.Attended)
                    .CountAsync(cancellationToken);

                // Update user stats
                user.TotalPoints = totalPoints;
                user.TotalCleanups = totalCleanups;
                user.TotalEventsOrganized = totalEventsOrganized;
                user.TotalEventsParticipated = totalEventsParticipated;
                user.UpdatedAt = DateTime.UtcNow;

                _context.Users.Update(user);
                await _context.SaveChangesAsync(cancellationToken);

                _logger.LogInformation("Recalculated stats for user {UserId}: Points={Points}, Cleanups={Cleanups}, EventsOrganized={EventsOrganized}, EventsParticipated={EventsParticipated}",
                    userId, totalPoints, totalCleanups, totalEventsOrganized, totalEventsParticipated);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to recalculate stats for user {UserId}", userId);
                throw;
            }
        }
    }
}
