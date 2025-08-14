using AutoMapper;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace EcoChallenge.Services.Services
{
    public class NotificationService :
       BaseCRUDService<NotificationResponse, NotificationSearchObject, Notification, NotificationInsertRequest, NotificationUpdateRequest>,
       INotificationService
    {
        private readonly ILogger<NotificationService> _logger;
        public NotificationService(EcoChallengeDbContext db, IMapper mapper, ILogger<NotificationService> logger) : base(db, mapper)
        {
            _logger = logger;
        }

        protected override IQueryable<Notification> ApplyFilter(IQueryable<Notification> query, NotificationSearchObject s)
        {
            if (s.UserId.HasValue)
                query = query.Where(n => n.UserId == s.UserId.Value);

            if (s.NotificationType.HasValue)
                query = query.Where(n => n.NotificationType == s.NotificationType.Value);

            if (s.IsRead.HasValue)
                query = query.Where(n => n.IsRead == s.IsRead.Value);

            if (s.IsPushed.HasValue)
                query = query.Where(n => n.IsPushed == s.IsPushed.Value);

            return query;
        }

        protected override async Task BeforeInsert(Notification entity, NotificationInsertRequest request, CancellationToken cancellationToken = default)
        {
            entity.CreatedAt = DateTime.UtcNow;
            entity.IsRead = false;

            await base.BeforeInsert(entity, request, cancellationToken);
        }

        public async Task<List<NotificationResponse>> CreateBulkAsync(List<NotificationInsertRequest> requests, CancellationToken cancellationToken = default)
        {
            try
            {
                var entities = new List<Notification>();
                var now = DateTime.UtcNow;

                foreach (var request in requests)
                {
                    var entity = new Notification
                    {
                        UserId = request.UserId,
                        NotificationType = request.NotificationType,
                        Title = request.Title,
                        Message = request.Message,
                        IsPushed = request.IsPushed,
                        IsRead = false,
                        CreatedAt = now
                    };
                    entities.Add(entity);
                }

                _context.Set<Notification>().AddRange(entities);
                await _context.SaveChangesAsync(cancellationToken);

                var responses = entities.Select(MapToResponse).ToList();

                _logger.LogInformation("Created {Count} notifications in bulk", entities.Count);

                return responses;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create bulk notifications");
                throw;
            }
        }

        // Mark notifications as read
        public async Task<bool> MarkAsReadAsync(int notificationId, CancellationToken cancellationToken = default)
        {
            try
            {
                var notification = await _context.Set<Notification>().FindAsync(new object[] { notificationId }, cancellationToken);
                if (notification == null)
                    return false;

                notification.IsRead = true;
                notification.ReadAt = DateTime.UtcNow;

                await _context.SaveChangesAsync(cancellationToken);
                return true;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to mark notification {NotificationId} as read", notificationId);
                return false;
            }
        }

        // Mark multiple notifications as read for a user
        public async Task<int> MarkAllAsReadAsync(int userId, CancellationToken cancellationToken = default)
        {
            try
            {
                var unreadNotifications = await _context.Set<Notification>()
                    .Where(n => n.UserId == userId && !n.IsRead)
                    .ToListAsync(cancellationToken);

                var now = DateTime.UtcNow;
                foreach (var notification in unreadNotifications)
                {
                    notification.IsRead = true;
                    notification.ReadAt = now;
                }

                await _context.SaveChangesAsync(cancellationToken);

                _logger.LogInformation("Marked {Count} notifications as read for user {UserId}", unreadNotifications.Count, userId);

                return unreadNotifications.Count;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to mark all notifications as read for user {UserId}", userId);
                return 0;
            }
        }
    }
}
