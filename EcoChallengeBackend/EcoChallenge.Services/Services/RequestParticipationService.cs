using AutoMapper;
using EcoChallenge.Models.Enums;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using EcoChallenge.Models.Messages;
using Microsoft.Extensions.DependencyInjection;

namespace EcoChallenge.Services.Services
{
    public class RequestParticipationService : BaseCRUDService<RequestParticipationResponse, RequestParticipationSearchObject, RequestParticipation, RequestParticipationInsertRequest, RequestParticipationUpdateRequest>, IRequestParticipationService
    {
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;
        private readonly IRabbitMQService _rabbitMQService;
        private readonly INotificationService _notificationService;
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<RequestParticipationService> _logger;


        public RequestParticipationService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService, IRabbitMQService rabbitMQService,
            INotificationService notificationService,
            IServiceProvider serviceProvider,
            ILogger<RequestParticipationService> logger) : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
            _rabbitMQService = rabbitMQService;
            _notificationService = notificationService;
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override IQueryable<RequestParticipation> ApplyFilter(IQueryable<RequestParticipation> query, RequestParticipationSearchObject search)
        {
            query = query
                .Include(x => x.Photos)
                .Include(x => x.User)
                .Include(x => x.Request);

            if (search.UserId.HasValue)
                query = query.Where(x => x.UserId == search.UserId.Value);

            if (search.RequestId.HasValue)
                query = query.Where(x => x.RequestId == search.RequestId.Value);

            if (search.Status.HasValue)
                query = query.Where(x => x.Status == search.Status.Value);

            return query;
        }

        protected override async Task BeforeInsert(RequestParticipation entity, RequestParticipationInsertRequest request, CancellationToken cancellationToken = default)
        {
            entity.SubmittedAt = DateTime.UtcNow;

            if (request.Photos != null && request.Photos.Any())
            {
                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = request.UserId,
                        PhotoType = PhotoType.After,
                        IsPrimary = false
                    });
                }
            }

            await base.BeforeInsert(entity, request, cancellationToken);
        }

        protected override async Task BeforeUpdate(RequestParticipation entity, RequestParticipationUpdateRequest request, CancellationToken cancellationToken = default)
        {
            var originalStatus = entity.Status;

            if (request.Photos != null && request.Photos.Any())
            {
                var existingPhotos = await _db.Photos
                    .Where(p => p.RequestId == entity.Id)
                    .ToListAsync(cancellationToken);

                _db.Photos.RemoveRange(existingPhotos);

                entity.Photos = new List<Photo>();
                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.After,
                        IsPrimary = false
                    });
                }
            }

            await base.BeforeUpdate(entity, request, cancellationToken);
            if (request.Status.HasValue && request.Status.Value != originalStatus)
            {
                var newStatus = request.Status.Value;

                _ = Task.Run(async () =>
                {
                    await CreateParticipationStatusNotificationAsync(entity, originalStatus, newStatus, request);
                });

                // Only publish for Approved or Denied status changes
                if (newStatus == ParticipationStatus.Approved || newStatus == ParticipationStatus.Rejected)
                {
                    _ = Task.Run(async () =>
                    {
                        try
                        {
                            var badgeService = _serviceProvider.GetRequiredService<IBadgeManagementService>();
                            await badgeService.CheckAndAwardBadgesAsync(entity.UserId);
                        }
                        catch (Exception ex)
                        {
                            _logger.LogError(ex, "Failed to check badges for user {UserId} after participation approval", entity.UserId);
                        }
                    });
                    await PublishProofStatusChangedMessage(entity, originalStatus, newStatus, request, cancellationToken);
                }
            }
        }

        private async Task CreateParticipationStatusNotificationAsync(RequestParticipation entity, ParticipationStatus originalStatus, ParticipationStatus newStatus, RequestParticipationUpdateRequest request)
        {
            try
            {
                // Get request information for better notification context
                var requestEntity = await _db.Requests
                    .FirstOrDefaultAsync(r => r.Id == entity.RequestId);

                string requestTitle = requestEntity?.Title ?? "Unknown Request";

                NotificationType notificationType;
                string title;
                string message;

                switch (newStatus)
                {
                    case ParticipationStatus.Approved:
                        notificationType = NotificationType.RewardReceived;
                        title = "Participation Approved! 🎉";
                        message = $"Congratulations! Your participation in '{requestTitle}' has been approved";

                        if (request.RewardPoints > 0 || request.RewardMoney > 0)
                        {
                            message += $" and you've earned {request.RewardPoints} points";
                            if (request.RewardMoney > 0)
                                message += $" and ${request.RewardMoney}";
                            message += " as a reward";
                        }
                        message += ". Thank you for making a positive impact!";
                        break;

                    case ParticipationStatus.Rejected:
                        notificationType = NotificationType.AdminMessage;
                        title = "Participation Update";
                        message = $"Your participation proof for '{requestTitle}' needs some adjustments.";

                        if (!string.IsNullOrEmpty(request.RejectionReason))
                            message += $" Feedback: {request.RejectionReason}";

                        message += " You can resubmit your participation with updated proof.";
                        break;

                    default:
                        notificationType = NotificationType.AdminMessage;
                        title = "Participation Status Updated";
                        message = $"Your participation status for '{requestTitle}' has been updated to {newStatus}.";
                        break;
                }

                var notificationRequest = new NotificationInsertRequest
                {
                    UserId = entity.UserId,
                    NotificationType = notificationType,
                    Title = title,
                    Message = message,
                    IsPushed = false
                };

                await _notificationService.CreateAsync(notificationRequest);

                _logger.LogInformation("Created notification for user {UserId} regarding participation {ParticipationId} status change to {NewStatus}",
                    entity.UserId, entity.Id, newStatus);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create notification for participation {ParticipationId} status change", entity.Id);
                // Don't throw - we don't want to fail the main operation
            }
        }

        private async Task PublishProofStatusChangedMessage(
           RequestParticipation entity,
           ParticipationStatus originalStatus,
           ParticipationStatus newStatus,
           RequestParticipationUpdateRequest request,
           CancellationToken cancellationToken)
        {
            try
            {
                // Get user and request information
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Id == entity.UserId, cancellationToken);

                var requestEntity = await _context.Requests
                    .FirstOrDefaultAsync(r => r.Id == entity.RequestId, cancellationToken);

                // Get admin information if available
                User? admin = null;
                // You might need to add AdminId to RequestParticipationUpdateRequest or get it from context
                // For now, we'll leave it null - you can modify based on your needs

                var message = new ProofStatusChanged
                {
                    ParticipationId = entity.Id,
                    RequestId = entity.RequestId,
                    UserId = entity.UserId,
                    UserEmail = user?.Email ?? string.Empty,
                    UserName = $"{user?.FirstName} {user?.LastName}".Trim(),
                    RequestTitle = requestEntity?.Title ?? "Untitled Request",
                    OldStatus = originalStatus.ToString(),
                    NewStatus = newStatus.ToString(),
                    AdminNotes = request.AdminNotes,
                    RejectionReason = request.RejectionReason,
                    ChangedAt = DateTime.UtcNow,
                    AdminId = admin?.Id,
                    AdminName = admin != null ? $"{admin.FirstName} {admin.LastName}".Trim() : null,
                    RewardPoints = request.RewardPoints,
                    RewardMoney = request.RewardMoney,
                    CardHolderName = request.CardHolderName,
                    BankName = request.BankName,
                    TransactionNumber = request.TransactionNumber
                };

                // Determine routing key based on new status
                var routingKey = newStatus switch
                {
                    ParticipationStatus.Approved => "proof.status.approved",
                    ParticipationStatus.Rejected => "proof.status.denied",
                    _ => "proof.status.changed"
                };

                await _rabbitMQService.PublishAsync(message, routingKey);

                _logger.LogInformation("Published ProofStatusChanged message for Participation {ParticipationId}, Status: {OldStatus} -> {NewStatus}",
                    entity.Id, originalStatus, newStatus);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish ProofStatusChanged message for Participation {ParticipationId}", entity.Id);
                // Don't throw - we don't want to fail the update operation because of messaging issues
            }
        }
    }
}
