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
            builder.Entity<BadgeType>().HasData(
                new BadgeType { Id = 1, Name = "Participation" },
                new BadgeType { Id = 2, Name = "Achievement" },
                new BadgeType { Id = 3, Name = "Milestone" },
                new BadgeType { Id = 4, Name = "Special" }
            );

            builder.Entity<CriteriaType>().HasData(
                new CriteriaType { Id = 1, Name = "Count" },
                new CriteriaType { Id = 2, Name = "Points" },
                new CriteriaType { Id = 3, Name = "EventsOrganized" },
                new CriteriaType { Id = 4, Name = "DonationsMade" },
                new CriteriaType { Id = 5, Name = "Special" }
            );

            builder.Entity<DonationStatus>().HasData(
                new DonationStatus { Id = 1, Name = "Pending" },
                new DonationStatus { Id = 2, Name = "Completed" },
                new DonationStatus { Id = 3, Name = "Failed" }
            );

            builder.Entity<EntityType>().HasData(
                new EntityType { Id = 1, Name = "Request" },
                new EntityType { Id = 2, Name = "Event" },
                new EntityType { Id = 3, Name = "Donation" },
                new EntityType { Id = 4, Name = "Badge" },
                new EntityType { Id = 5, Name = "Reward" },
                new EntityType { Id = 6, Name = "Message" },
                new EntityType { Id = 7, Name = "Gallery" },
                new EntityType { Id = 8, Name = "User " }
            );

            builder.Entity<EventStatus>().HasData(
                new EventStatus { Id = 1, Name = "Draft" },
                new EventStatus { Id = 2, Name = "Published" },
                new EventStatus { Id = 3, Name = "Completed" },
                new EventStatus { Id = 4, Name = "InProgress" },
                new EventStatus { Id = 5, Name = "Cancelled" }
            );

            builder.Entity<EventType>().HasData(
                new EventType { Id = 1, Name = "Cleanup" },
                new EventType { Id = 2, Name = "Community " },
                new EventType { Id = 3, Name = "Fundraiser" }
            );

            builder.Entity<RequestStatus>().HasData(
                new RequestStatus { Id = 1, Name = "Pending" },
                new RequestStatus { Id = 2, Name = "UnderReview" },
                new RequestStatus { Id = 3, Name = "Approved" },
                new RequestStatus { Id = 4, Name = "Rejected" },
                new RequestStatus { Id = 5, Name = "InProgress" },
                new RequestStatus { Id = 6, Name = "Completed" },
                new RequestStatus { Id = 7, Name = "Cancelled " }
            );

            builder.Entity<RewardType>().HasData(
                new RewardType { Id = 1, Name = "Points" },
                new RewardType { Id = 2, Name = "Money" },
                new RewardType { Id = 3, Name = "Badge" },
                new RewardType { Id = 4, Name = "Combo" }
            );

            builder.Entity<TargetEntityType>().HasData(
                new TargetEntityType { Id = 1, Name = "User" },
                new TargetEntityType { Id = 2, Name = "Request" },
                new TargetEntityType { Id = 3, Name = "Event" },
                new TargetEntityType { Id = 4, Name = "Reward" },
                new TargetEntityType { Id = 5, Name = "Organization" },
                new TargetEntityType { Id = 6, Name = "System " }
            );

            builder.Entity<UserType>().HasData(
                new UserType { Id = 1, Name = "Admin" },
                new UserType { Id = 2, Name = "User" },
                new UserType { Id = 3, Name = "Moderator" },
                new UserType { Id = 4, Name = "Finance" }
            );

            builder.Entity<WasteType>().HasData(
                new WasteType { Id = 1, Name = "Plastic" },
                new WasteType { Id = 2, Name = "Glass" },
                new WasteType { Id = 3, Name = "Metal" },
                new WasteType { Id = 4, Name = "Organic" },
                new WasteType { Id = 5, Name = "Mixed" },
                new WasteType { Id = 6, Name = "Hazardous" },
                new WasteType { Id = 7, Name = "Other " }
            );

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
           UserTypeId = 1,
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
           UserTypeId = 2,
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
           UserTypeId = 4,
           CreatedAt = new DateTime(2025, 1, 3),
           UpdatedAt = new DateTime(2025, 1, 3)
       }
   );

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
                    CriteriaTypeId = 1,
                    CriteriaValue = 1,
                    BadgeTypeId = 3,
                    CreatedAt = new DateTime(2025, 4, 1)
                },
                new Badge
                {
                    Id = 2,
                    Name = "Donation Star",
                    CriteriaTypeId = 4,
                    CriteriaValue = 1,
                    BadgeTypeId = 2,
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
                    WasteTypeId = 5,
                    EstimatedAmount = EstimatedAmount.Small,
                    StatusId = 1,
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
                    WasteTypeId = 1,
                    EstimatedAmount = EstimatedAmount.Large,
                    StatusId = 2,
                    CreatedAt = new DateTime(2025, 6, 2),
                    UpdatedAt = new DateTime(2025, 6, 2),
                    AssignedAdminId = 1    // alice
                }
            );

            builder.Entity<Event>().HasData(
                new Event
                {
                    Id = 1,
                    CreatorUserId = 1,     // alice
                    LocationId = 1,
                    Title = "Park Cleanup",
                    EventTypeId = 1,
                    EventDate = new DateTime(2025, 7, 1),
                    EventTime = new TimeSpan(9, 0, 0),
                    StatusId = 2,
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
                    EventTypeId = 2,
                    EventDate = new DateTime(2025, 7, 5),
                    EventTime = new TimeSpan(14, 0, 0),
                    StatusId = 1,
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
                    StatusId = 2,
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
                    RewardTypeId = 1,
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
                    RewardTypeId = 3,
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
                    RelatedEntityTypeId = 1,
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
                    TargetEntityTypeId = 2,
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
                    EntityTypeId = 2,
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
