using EcoChallenge.Models.Enums;
using EcoChallenge.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database
{
    public static class ModelBuilderExtensions
    {
        public static void SeedTestData(this ModelBuilder builder)
        {
            builder.Entity<User>().HasData(
       new User
       {
           Id = 1,
           Username = "alice",
           Email = "alice@example.com",
           PasswordHash = "HASH1",
           FirstName = "Alice",
           LastName = "Anderson",
           City = "Mostar",
           Country = "BiH",
           UserType = UserType.Admin,
           CreatedAt = new DateTime(2025, 1, 1),
           UpdatedAt = new DateTime(2025, 1, 1)
       },
       new User
       {
           Id = 2,
           Username = "bob",
           Email = "bob@example.com",
           PasswordHash = "HASH2",
           FirstName = "Bob",
           LastName = "Baker",
           City = "Sarajevo",
           Country = "BiH",
           UserType = UserType.User,
           CreatedAt = new DateTime(2025, 1, 2),
           UpdatedAt = new DateTime(2025, 1, 2)
       },
       new User
       {
           Id = 3,
           Username = "carol",
           Email = "carol@example.com",
           PasswordHash = "HASH3",
           FirstName = "Carol",
           LastName = "Clark",
           City = "Mostar",
           Country = "BiH",
           UserType = UserType.Moderator,
           CreatedAt = new DateTime(2025, 1, 3),
           UpdatedAt = new DateTime(2025, 1, 3)
       }
   );

            // 2) Organizations
            builder.Entity<Organization>().HasData(
                new Organization
                {
                    Id = 1,
                    Name = "GreenEarth",
                    Description = "Environmental NGO",
                    Website = "https://greenearth.org",
                    ContactEmail = "contact@greenearth.org",
                    CreatedAt = new DateTime(2025, 2, 1),
                    UpdatedAt = new DateTime(2025, 2, 1)
                },
                new Organization
                {
                    Id = 2,
                    Name = "OceanCare",
                    Description = "Marine conservation group",
                    Website = "https://oceancare.org",
                    ContactEmail = "info@oceancare.org",
                    CreatedAt = new DateTime(2025, 2, 2),
                    UpdatedAt = new DateTime(2025, 2, 2)
                }
            );

            // 3) Locations
            builder.Entity<Location>().HasData(
                new Location
                {
                    Id = 1,
                    Name = "Riverbank Park",
                    Latitude = 43.3436m,
                    Longitude = 17.8083m,
                    City = "Mostar",
                    Country = "BiH",
                    LocationType = LocationType.Park,
                    CreatedAt = new DateTime(2025, 3, 1)
                },
                new Location
                {
                    Id = 2,
                    Name = "City Beach",
                    Latitude = 42.4300m,
                    Longitude = 18.6413m,
                    City = "Neum",
                    Country = "BiH",
                    LocationType = LocationType.Coastal,
                    CreatedAt = new DateTime(2025, 3, 2)
                }
            );

            // 4) Badges
            builder.Entity<Badge>().HasData(
                new Badge
                {
                    Id = 1,
                    Name = "First Cleanup",
                    CriteriaType = CriteriaType.CleanupsCount,
                    CriteriaValue = 1,
                    BadgeType = BadgeType.Milestone,
                    CreatedAt = new DateTime(2025, 4, 1)
                },
                new Badge
                {
                    Id = 2,
                    Name = "Donation Star",
                    CriteriaType = CriteriaType.DonationsMade,
                    CriteriaValue = 1,
                    BadgeType = BadgeType.Achievement,
                    CreatedAt = new DateTime(2025, 4, 2)
                }
            );

            // 5) SystemSettings
            builder.Entity<SystemSetting>().HasData(
                new SystemSetting
                {
                    Id = 1,
                    Key = "default_points_per_cleanup",
                    Value = "50",
                    Type = SettingType.Integer,
                    IsPublic = true,
                    CreatedAt = new DateTime(2025, 5, 1),
                    UpdatedAt = new DateTime(2025, 5, 1)
                },
                new SystemSetting
                {
                    Id = 2,
                    Key = "maintenance_mode",
                    Value = "false",
                    Type = SettingType.Boolean,
                    IsPublic = false,
                    CreatedAt = new DateTime(2025, 5, 2),
                    UpdatedAt = new DateTime(2025, 5, 2)
                }
            );

            // 6) Requests
            builder.Entity<Request>().HasData(
                new Request
                {
                    Id = 1,
                    UserId = 2,            // bob
                    LocationId = 1,        // Riverbank Park
                    Title = "Trash at Park",
                    UrgencyLevel = UrgencyLevel.Medium,
                    WasteType = WasteType.Mixed,
                    EstimatedAmount = EstimatedAmount.Small,
                    Status = RequestStatus.Pending,
                    CreatedAt = new DateTime(2025, 6, 1),
                    UpdatedAt = new DateTime(2025, 6, 1)
                },
                new Request
                {
                    Id = 2,
                    UserId = 3,            // carol
                    LocationId = 2,        // City Beach
                    Title = "Plastic on Beach",
                    UrgencyLevel = UrgencyLevel.High,
                    WasteType = WasteType.Plastic,
                    EstimatedAmount = EstimatedAmount.Large,
                    Status = RequestStatus.UnderReview,
                    CreatedAt = new DateTime(2025, 6, 2),
                    UpdatedAt = new DateTime(2025, 6, 2),
                    AssignedAdminId = 1    // alice
                }
            );

            // 7) Events
            builder.Entity<Event>().HasData(
                new Event
                {
                    Id = 1,
                    CreatorUserId = 1,     // alice
                    LocationId = 1,
                    Title = "Park Cleanup",
                    EventType = EventType.Cleanup,
                    EventDate = new DateTime(2025, 7, 1),
                    EventTime = new TimeSpan(9, 0, 0),
                    Status = EventStatus.Published,
                    CreatedAt = new DateTime(2025, 6, 10),
                    UpdatedAt = new DateTime(2025, 6, 10),
                    RelatedRequestId = 1
                },
                new Event
                {
                    Id = 2,
                    CreatorUserId = 3,     // carol
                    LocationId = 2,
                    Title = "Beach Education",
                    EventType = EventType.Educational,
                    EventDate = new DateTime(2025, 7, 5),
                    EventTime = new TimeSpan(14, 0, 0),
                    Status = EventStatus.Draft,
                    CreatedAt = new DateTime(2025, 6, 11),
                    UpdatedAt = new DateTime(2025, 6, 11)
                }
            );

            // 8) EventParticipants
            builder.Entity<EventParticipant>().HasData(
                new EventParticipant
                {
                    Id = 1,
                    EventId = 1,
                    UserId = 2,
                    JoinedAt = new DateTime(2025, 6, 15),
                    Status = AttendanceStatus.Registered,
                    PointsEarned = 0
                },
                new EventParticipant
                {
                    Id = 2,
                    EventId = 1,
                    UserId = 3,
                    JoinedAt = new DateTime(2025, 6, 16),
                    Status = AttendanceStatus.Registered,
                    PointsEarned = 0
                }
            );

            // 9) ChatMessages
            builder.Entity<ChatMessage>().HasData(
                new ChatMessage
                {
                    Id = 1,
                    EventId = 1,
                    SenderUserId = 2,
                    MessageText = "Looking forward to helping!",
                    MessageType = MessageType.Text,
                    SentAt = new DateTime(2025, 6, 20)
                }
            );

            // 10) Donations
            builder.Entity<Donation>().HasData(
                new Donation
                {
                    Id = 1,
                    UserId = 2,
                    OrganizationId = 1,
                    Amount = 20.00m,
                    Status = DonationStatus.Completed,
                    CreatedAt = new DateTime(2025, 6, 5),
                    ProcessedAt = new DateTime(2025, 6, 6)
                }
            );

            // 11) Rewards
            builder.Entity<Reward>().HasData(
                new Reward
                {
                    Id = 1,
                    UserId = 2,
                    RequestId = 1,
                    RewardType = RewardType.Points,
                    PointsAmount = 50,
                    Currency = "USD",
                    Status = RewardStatus.Approved,
                    CreatedAt = new DateTime(2025, 6, 7),
                    ApprovedAt = new DateTime(2025, 6, 8)
                },
                new Reward
                {
                    Id = 2,
                    UserId = 2,
                    DonationId = 1,
                    RewardType = RewardType.Badge,
                    BadgeId = 2,
                    Status = RewardStatus.Paid,
                    CreatedAt = new DateTime(2025, 6, 10),
                    PaidAt = new DateTime(2025, 6, 11)
                }
            );

            // 12) UserBadges
            builder.Entity<UserBadge>().HasData(
                new UserBadge
                {
                    Id = 1,
                    UserId = 2,
                    BadgeId = 1,
                    EarnedAt = new DateTime(2025, 6, 9)
                }
            );

            // 13) Gallery
            builder.Entity<Gallery>().HasData(
                new Gallery
                {
                    Id = 1,
                    RequestId = 1,
                    LocationId = 1,
                    UserId = 2,
                    ImageUrl = "/images/before1.jpg",
                    ImageType = ImageType.Before,
                    UploadedAt = new DateTime(2025, 6, 2)
                },
                new Gallery
                {
                    Id = 2,
                    EventId = 1,
                    LocationId = 1,
                    UserId = 3,
                    ImageUrl = "/images/during1.jpg",
                    ImageType = ImageType.During,
                    UploadedAt = new DateTime(2025, 7, 1)
                }
            );

            // 14) GalleryReactions
            builder.Entity<GalleryReaction>().HasData(
                new GalleryReaction
                {
                    Id = 1,
                    GalleryId = 1,
                    UserId = 3,
                    ReactionType = ReactionType.Like,
                    CreatedAt = new DateTime(2025, 6, 3)
                }
            );

            // 15) ActivityHistory
            builder.Entity<ActivityHistory>().HasData(
                new ActivityHistory
                {
                    Id = 1,
                    UserId = 2,
                    ActivityType = ActivityType.RequestCreated,
                    RelatedEntityType = EntityType.Request,
                    RelatedEntityId = 1,
                    PointsEarned = 0,
                    CreatedAt = new DateTime(2025, 6, 1)
                }
            );

            // 16) AdminLog
            builder.Entity<AdminLog>().HasData(
                new AdminLog
                {
                    Id = 1,
                    AdminUserId = 1,
                    ActionType = AdminActionType.ApproveRequest,
                    TargetEntityType = TargetEntityType.Request,
                    TargetEntityId = 2,
                    CreatedAt = new DateTime(2025, 6, 2),
                    ActionDescription = "Approved request #2"
                }
            );

            // 17) Reports
            builder.Entity<Report>().HasData(
                new Report
                {
                    Id = 1,
                    ReporterUserId = 3,
                    EntityType = TargetEntityType.User,
                    EntityId = 2,
                    Reason = ReportReason.Spam,
                    Status = ReportStatus.Pending,
                    CreatedAt = new DateTime(2025, 6, 15)
                }
            );

            // 18) Notifications
            builder.Entity<Notification>().HasData(
                new Notification
                {
                    Id = 1,
                    UserId = 2,
                    NotificationType = NotificationType.RequestApproved,
                    Title = "Your cleanup request was approved",
                    Message = "We’ve approved your request #1. Thank you!",
                    CreatedAt = new DateTime(2025, 6, 8)
                },
                new Notification
                {
                    Id = 2,
                    UserId = 2,
                    NotificationType = NotificationType.EventReminder,
                    Title = "Reminder: Park Cleanup tomorrow",
                    Message = "Don’t forget our Park Cleanup event on 2025-07-01 at 09:00.",
                    CreatedAt = new DateTime(2025, 6, 30)
                }
            );
        }
    }
}
