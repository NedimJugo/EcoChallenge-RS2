using AutoMapper;
using AutoMapper.QueryableExtensions;
using EcoChallenge.Models.AI_Models;
using EcoChallenge.Models.Enums;
using EcoChallenge.Models.Messages;
using EcoChallenge.Models.Requests;
using EcoChallenge.Models.Responses;
using EcoChallenge.Models.SearchObjects;
using EcoChallenge.Services.BaseServices;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Services
{
    public class RequestService : BaseCRUDService<RequestResponse, RequestSearchObject, Request, RequestInsertRequest, RequestUpdateRequest>, IRequestService
    {
        private readonly EcoChallengeDbContext _db;
        private readonly IBlobService _blobService;
        private readonly IAzureVisionService _azureVisionService;
        private readonly IMLPricingService _mlPricingService;
        private readonly IRabbitMQService _rabbitMQService;
        private readonly INotificationService _notificationService;
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<RequestService> _logger;

        public RequestService(EcoChallengeDbContext db, IMapper mapper, IBlobService blobService, IAzureVisionService azureVisionService,
        IMLPricingService mlPricingService,
        IRabbitMQService rabbitMQService,
        INotificationService notificationService,
        IServiceProvider serviceProvider,
        ILogger<RequestService> logger) : base(db, mapper)
        {
            _db = db;
            _blobService = blobService;
            _azureVisionService = azureVisionService;
            _mlPricingService = mlPricingService;
            _rabbitMQService = rabbitMQService;
            _notificationService = notificationService;
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override IQueryable<Request> ApplyFilter(IQueryable<Request> query, RequestSearchObject s)
        {
            query = query
               .Include(r => r.User)
               .Include(r => r.Location)
               .Include(r => r.WasteType)
               .Include(r => r.Status)
               .Include(r => r.AssignedAdmin)
               .Include(r => r.Photos);
            if (!string.IsNullOrWhiteSpace(s.Text))
            {
                var t = s.Text.ToLower();
                query.Where(r =>
                    r.Title!.ToLower().Contains(t) ||
                    r.Description!.ToLower().Contains(t) ||
                    r.AdminNotes!.ToLower().Contains(t) ||
                    r.RejectionReason!.ToLower().Contains(t));
            }

            if (s.Status.HasValue)
                query = query.Where(r => r.StatusId == s.Status.Value);

            if (s.WasteTypeId.HasValue)
                query = query.Where(r => r.WasteTypeId == s.WasteTypeId.Value);

            if (s.UrgencyLevel.HasValue)
                query = query.Where(r => r.UrgencyLevel == s.UrgencyLevel.Value);

            if (s.EstimatedAmount.HasValue)
                query = query.Where(r => r.EstimatedAmount == s.EstimatedAmount.Value);

            if (s.LocationId.HasValue)
                query = query.Where(r => r.LocationId == s.LocationId.Value);

            if (s.UserId.HasValue)
                query = query.Where(r => r.UserId == s.UserId.Value);

            if (s.AssignedAdminId.HasValue)
                query = query.Where(r => r.AssignedAdminId == s.AssignedAdminId.Value);

            return query;
        }


        public override async Task<RequestResponse?> GetByIdAsync(int id, CancellationToken cancellationToken = default)
        {
            var entity = await _context.Requests
                .Include(r => r.User)
                .Include(r => r.Location)
                .Include(r => r.WasteType)
                .Include(r => r.Status)
                .Include(r => r.AssignedAdmin)
                .Include(r => r.Photos)
                .FirstOrDefaultAsync(r => r.Id == id, cancellationToken);

            return entity == null ? null : MapToResponse(entity);
        }


        // Services/Services/RequestService.cs - Updated BeforeInsert method
        protected override async Task BeforeInsert(Request entity, RequestInsertRequest request, CancellationToken cancellationToken = default)
        {

            // Validate and set default StatusId if not provided or invalid
            if (entity.StatusId <= 0)
            {
                // Get default status (e.g., "Pending" or "New")
                var defaultStatus = await _context.RequestStatuses
                    .FirstOrDefaultAsync(s => s.Name.ToLower() == "pending" || s.Name.ToLower() == "new", cancellationToken);

                if (defaultStatus != null)
                {
                    entity.StatusId = defaultStatus.Id;
                }
                else
                {
                    // If no default status found, create one or use ID 1
                    entity.StatusId = 1; // Adjust based on your database
                }
            }
            else
            {
                // Validate that the provided StatusId exists
                var statusExists = await _context.RequestStatuses
                    .AnyAsync(s => s.Id == entity.StatusId, cancellationToken);

                if (!statusExists)
                {
                    throw new ArgumentException($"Invalid StatusId: {entity.StatusId}");
                }
            }

            // Validate and set default WasteTypeId if not provided or invalid
            if (entity.WasteTypeId <= 0)
            {
                // Get default waste type (e.g., "Mixed" or "General")
                var defaultWasteType = await _context.WasteTypes
                    .FirstOrDefaultAsync(w => w.Name.ToLower() == "mixed" || w.Name.ToLower() == "general", cancellationToken);

                if (defaultWasteType != null)
                {
                    entity.WasteTypeId = defaultWasteType.Id;
                }
                else
                {
                    // If no default waste type found, create one or use ID 1
                    entity.WasteTypeId = 1; // Adjust based on your database
                }
            }
            else
            {
                // Validate that the provided WasteTypeId exists
                var wasteTypeExists = await _context.WasteTypes
                    .AnyAsync(w => w.Id == entity.WasteTypeId, cancellationToken);

                if (!wasteTypeExists)
                {
                    throw new ArgumentException($"Invalid WasteTypeId: {entity.WasteTypeId}");
                }
            }

            // Validate other required foreign keys
            if (entity.UserId > 0)
            {
                var userExists = await _context.Users
                    .AnyAsync(u => u.Id == entity.UserId, cancellationToken);

                if (!userExists)
                {
                    throw new ArgumentException($"Invalid UserId: {entity.UserId}");
                }
            }

            if (entity.LocationId > 0)
            {
                var locationExists = await _context.Locations
                    .AnyAsync(l => l.Id == entity.LocationId, cancellationToken);

                if (!locationExists)
                {
                    throw new ArgumentException($"Invalid LocationId: {entity.LocationId}");
                }
            }

            if (request.Photos != null && request.Photos.Any())
            {
                entity.Photos = new List<Photo>();
                var imageUrls = new List<string>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    imageUrls.Add(url);

                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0
                    });
                }

                try
                {
                    var wasteAnalysis = await _azureVisionService.AnalyzeMultipleImagesAsync(imageUrls);
                    entity.AiAnalysisResult = JsonConvert.SerializeObject(wasteAnalysis);

                    // Get ML pricing recommendation
                    var pricingRecommendation = await _mlPricingService.PredictPricingAsync(wasteAnalysis, entity);

                    entity.SuggestedRewardMoney = pricingRecommendation.SuggestedRewardMoney;
                    entity.SuggestedRewardPoints = pricingRecommendation.SuggestedRewardPoints;

                    _logger.LogInformation("AI analysis completed for request. Suggested reward: ${Money}, {Points} points",
                        pricingRecommendation.SuggestedRewardMoney, pricingRecommendation.SuggestedRewardPoints);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error during AI analysis for request");
                    // Set default values if AI analysis fails
                    entity.SuggestedRewardMoney = 10m;
                    entity.SuggestedRewardPoints = 100;

                    // Store error information in AI analysis result
                    entity.AiAnalysisResult = JsonConvert.SerializeObject(new AggregatedWasteAnalysis
                    {
                        DominantWasteType = "mixed",
                        TotalEstimatedWeight = 5.0,
                        TotalEstimatedVolume = 0.1,
                        OverallQuantityLevel = "medium",
                        ProcessedImageUrls = imageUrls
                    });
                }
            }

            await base.BeforeInsert(entity, request, cancellationToken);

            _ = Task.Run(async () =>
            {
                try
                {
                    var badgeService = _serviceProvider.GetRequiredService<IBadgeManagementService>();
                    await badgeService.CheckRequestsBadgesAsync(entity.UserId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Failed to check badges for user {UserId} after request creation", entity.UserId);
                }
            });
        }

        public async Task RetrainMLModelAsync()
        {
            try
            {
                await _mlPricingService.TrainModelAsync();
                _logger.LogInformation("ML model retrained successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error retraining ML model");
                throw;
            }
        }

        public async Task ReanalyzeRequestAsync(int requestId)
        {
            var request = await _context.Requests
                .Include(r => r.Photos)
                .Include(r => r.Location)
                .FirstOrDefaultAsync(r => r.Id == requestId);

            if (request?.Photos?.Any() == true)
            {
                var imageUrls = request.Photos.Select(p => p.ImageUrl).ToList();

                try
                {
                    var wasteAnalysis = await _azureVisionService.AnalyzeMultipleImagesAsync(imageUrls);
                    request.AiAnalysisResult = JsonConvert.SerializeObject(wasteAnalysis);

                    var pricingRecommendation = await _mlPricingService.PredictPricingAsync(wasteAnalysis, request);
                    request.SuggestedRewardMoney = pricingRecommendation.SuggestedRewardMoney;
                    request.SuggestedRewardPoints = pricingRecommendation.SuggestedRewardPoints;

                    await _context.SaveChangesAsync();

                    _logger.LogInformation("Request {RequestId} reanalyzed successfully", requestId);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error reanalyzing request {RequestId}", requestId);
                    throw;
                }
            }
        }

        protected override async Task BeforeUpdate(Request entity, RequestUpdateRequest request, CancellationToken cancellationToken = default)
        {
            // Store original status for comparison
            var originalStatusId = entity.StatusId;
            string originalStatusName = string.Empty;
            string newStatusName = string.Empty;

            // Get original status name
            if (originalStatusId > 0)
            {
                var originalStatus = await _context.RequestStatuses
                    .FirstOrDefaultAsync(s => s.Id == originalStatusId, cancellationToken);
                originalStatusName = originalStatus?.Name ?? "Unknown";
            }

            if (request.Photos != null && request.Photos.Any())
            {
                var existingPhotos = await _context.Photos
                    .Where(p => p.RequestId == entity.Id)
                    .ToListAsync(cancellationToken);

                _context.Photos.RemoveRange(existingPhotos);

                entity.Photos = new List<Photo>();

                foreach (var file in request.Photos)
                {
                    var url = await _blobService.UploadFileAsync(file);
                    entity.Photos.Add(new Photo
                    {
                        ImageUrl = url,
                        UserId = entity.UserId,
                        PhotoType = PhotoType.General,
                        IsPrimary = entity.Photos.Count == 0
                    });
                }
            }

            await base.BeforeUpdate(entity, request, cancellationToken);

            if (request.StatusId.HasValue && request.StatusId.Value != originalStatusId)
            {
                // Get new status name
                var newStatus = await _context.RequestStatuses
                    .FirstOrDefaultAsync(s => s.Id == request.StatusId.Value, cancellationToken);
                newStatusName = newStatus?.Name ?? "Unknown";

                _ = Task.Run(async () =>
                {
                    await CreateRequestStatusNotificationAsync(entity, originalStatusName, newStatusName, request);
                });

                // Only publish for Approved or Denied status changes
                if (newStatusName.Equals("Approved", StringComparison.OrdinalIgnoreCase) ||
                    newStatusName.Equals("Denied", StringComparison.OrdinalIgnoreCase))
                {
                    await PublishRequestStatusChangedMessage(entity, originalStatusName, newStatusName, request, cancellationToken);
                }
            }
        }

        private async Task CreateRequestStatusNotificationAsync(Request entity, string originalStatus, string newStatus, RequestUpdateRequest request)
        {
            try
            {
                NotificationType notificationType;
                string title;
                string message;

                switch (newStatus.ToLower())
                {
                    case "approved":
                        notificationType = NotificationType.RequestApproved;
                        title = "Request Approved! 🎉";
                        message = $"Great news! Your cleanup request '{entity.Title}' has been approved";

                        if (request.ActualRewardPoints > 0 || request.ActualRewardMoney > 0)
                        {
                            message += $" with a reward of {request.ActualRewardPoints} points";
                            if (request.ActualRewardMoney > 0)
                                message += $" and ${request.ActualRewardMoney}";
                        }
                        message += ".";
                        break;

                    case "rejected":
                    case "denied":
                        notificationType = NotificationType.RequestRejected;
                        title = "Request Update";
                        message = $"Your cleanup request '{entity.Title}' has been declined.";

                        if (!string.IsNullOrEmpty(request.RejectionReason))
                            message += $" Reason: {request.RejectionReason}";
                        break;

                    case "completed":
                        notificationType = NotificationType.RequestApproved; // Using approved for completed
                        title = "Request Completed! ✅";
                        message = $"Your cleanup request '{entity.Title}' has been marked as completed. Thank you for making a difference!";
                        break;

                    default:
                        // For other status changes, create a general update notification
                        notificationType = NotificationType.AdminMessage;
                        title = "Request Status Updated";
                        message = $"Your cleanup request '{entity.Title}' status has been updated to {newStatus}.";
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

                _logger.LogInformation("Created notification for user {UserId} regarding request {RequestId} status change to {NewStatus}",
                    entity.UserId, entity.Id, newStatus);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to create notification for request {RequestId} status change", entity.Id);
                // Don't throw - we don't want to fail the main operation
            }
        }

        private async Task PublishRequestStatusChangedMessage(
          Request entity,
          string originalStatus,
          string newStatus,
          RequestUpdateRequest request,
          CancellationToken cancellationToken)
        {
            try
            {
                // Get user information
                var user = await _context.Users
                    .FirstOrDefaultAsync(u => u.Id == entity.UserId, cancellationToken);

                // Get admin information if available
                User? admin = null;
                if (request.AssignedAdminId.HasValue)
                {
                    admin = await _context.Users
                        .FirstOrDefaultAsync(u => u.Id == request.AssignedAdminId.Value, cancellationToken);
                }

                var message = new RequestStatusChanged
                {
                    RequestId = entity.Id,
                    UserId = entity.UserId,
                    UserEmail = user?.Email ?? string.Empty,
                    UserName = $"{user?.FirstName} {user?.LastName}".Trim(),
                    RequestTitle = entity.Title ?? "Untitled Request",
                    OldStatus = originalStatus,
                    NewStatus = newStatus,
                    AdminNotes = request.AdminNotes,
                    RejectionReason = request.RejectionReason,
                    ChangedAt = DateTime.UtcNow,
                    AdminId = admin?.Id,
                    AdminName = admin != null ? $"{admin.FirstName} {admin.LastName}".Trim() : null,
                    ActualRewardPoints = request.ActualRewardPoints,
                    ActualRewardMoney = request.ActualRewardMoney
                };

                // Determine routing key based on new status
                var routingKey = newStatus.ToLower() switch
                {
                    "approved" => "request.status.approved",
                    "denied" => "request.status.denied",
                    _ => "request.status.changed"
                };

                await _rabbitMQService.PublishAsync(message, routingKey);

                _logger.LogInformation("Published RequestStatusChanged message for Request {RequestId}, Status: {OldStatus} -> {NewStatus}",
                    entity.Id, originalStatus, newStatus);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Failed to publish RequestStatusChanged message for Request {RequestId}", entity.Id);
                // Don't throw - we don't want to fail the update operation because of messaging issues
            }
        }

    }
}
