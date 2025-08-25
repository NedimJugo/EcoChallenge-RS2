using EcoChallenge.Models.Enums;
using EcoChallenge.Services.Database.Entities;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Emit;
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
                new RequestStatus { Id = 2, Name = "Approved" },
                new RequestStatus { Id = 3, Name = "Rejected" },
                new RequestStatus { Id = 4, Name = "Completed" }
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
           Username = "desktop",
           Email = "alice@example.com",
           PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
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
           Username = "mobile",
           Email = "bob@example.com",
           PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
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
           PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
           FirstName = "Carol",
           LastName = "Clark",
           City = "Mostar",
           Country = "BiH",
           UserTypeId = 4,
           CreatedAt = new DateTime(2025, 1, 3),
           UpdatedAt = new DateTime(2025, 1, 3)
       },
        new User
        {
            Id = 4,
            Username = "david",
            Email = "david@example.com",
            PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
            FirstName = "David",
            LastName = "Davis",
            City = "Sarajevo",
            Country = "BiH",
            UserTypeId = 2,
            CreatedAt = new DateTime(2025, 1, 4),
            UpdatedAt = new DateTime(2025, 1, 4)
        },
    new User
    {
        Id = 5,
        Username = "eve",
        Email = "eve@example.com",
        PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
        FirstName = "Eve",
        LastName = "Evans",
        City = "Mostar",
        Country = "BiH",
        UserTypeId = 2,
        CreatedAt = new DateTime(2025, 1, 5),
        UpdatedAt = new DateTime(2025, 1, 5)
    },
    new User
    {
        Id = 6,
        Username = "frank",
        Email = "frank@example.com",
        PasswordHash = "100000.oyZoYudmUt4jDcDU1NfFeQ==.Gaukxx2FL2FeOV/Kl3eJWCq9xWJlaC9y7tXO4Spno34=",
        FirstName = "Frank",
        LastName = "Foster",
        City = "Sarajevo",
        Country = "BiH",
        UserTypeId = 2,
        CreatedAt = new DateTime(2025, 1, 6),
        UpdatedAt = new DateTime(2025, 1, 6)
    }
   );

            builder.Entity<Organization>().HasData(
                new Organization
                {
                    Id = 1,
                    Name = "GreenEarth",
                    Description = "Environmental NGO",
                    LogoUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/259-2593009_eco-logo-leaves-eco-friendly.png",
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
                    LogoUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/259-2593009_eco-logo-leaves-eco-friendly.png",
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
                },
                 new Location
                 {
                     Id = 3,
                     Name = "Downtown Square",
                     Latitude = 43.8564m,
                     Longitude = 18.4131m,
                     City = "Sarajevo",
                     Country = "BiH",
                     LocationType = LocationType.Urban,
                     CreatedAt = new DateTime(2025, 3, 3)
                 },
    new Location
    {
        Id = 4,
        Name = "Forest Trail",
        Latitude = 43.7000m,
        Longitude = 18.0000m,
        City = "Sarajevo",
        Country = "BiH",
        LocationType = LocationType.Forest,
        CreatedAt = new DateTime(2025, 3, 4)
    }
            );

            // 4) Badges
            builder.Entity<Badge>().HasData(
                 new Badge
                 {
                     Id = 1,
                     Name = "First Cleanup",
                     IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png",
                     CriteriaTypeId = 1,
                     CriteriaValue = 1,
                     BadgeTypeId = 3,
                     CreatedAt = new DateTime(2025, 4, 1)
                 },
                new Badge
                {
                    Id = 2,
                    Name = "Donation Star",
                    IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png",
                    CriteriaTypeId = 4,
                    CriteriaValue = 1,
                    BadgeTypeId = 2,
                    CreatedAt = new DateTime(2025, 4, 2)
                },
                new Badge
                {
                    Id = 3,
                    Name = "Eco Warrior",
                    Description = "Reached 1000 points",
                    IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/eco.png",
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
                    IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png",
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
        IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png",
        BadgeTypeId = 2, // Achievement
        CriteriaTypeId = 2, // Points
        CriteriaValue = 5000,
        IsActive = true,
        CreatedAt = new DateTime(2025, 1, 1)
    },

    // Activity count badges (requests + participations)
    new Badge
    {
        Id = 6,
        Name = "First Cleanup",
        Description = "Completed your first cleanup activity",
        IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png",
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
        IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/award.png",
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
        IconUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/badge.png",
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

    // Event organization badges
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

    // Event participation badges
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

    // Special/Milestone badges
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
                    SuggestedRewardMoney = 20.00m,
                    SuggestedRewardPoints = 100,
                    ActualRewardMoney = 20.00m,
                    ActualRewardPoints = 100,
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
                    SuggestedRewardMoney = 21.00m,
                    SuggestedRewardPoints = 100,
                    ActualRewardMoney = 20.00m,
                    ActualRewardPoints = 100,
                    StatusId = 2,
                    CreatedAt = new DateTime(2025, 6, 2),
                    UpdatedAt = new DateTime(2025, 6, 2),
                    AssignedAdminId = 1    // alice
                },
                 new Request
                 {
                     Id = 3,
                     UserId = 4,
                     LocationId = 3,
                     Title = "Downtown Street Cleanup",
                     UrgencyLevel = UrgencyLevel.Medium,
                     WasteTypeId = 5,
                     EstimatedAmount = EstimatedAmount.Medium,
                     SuggestedRewardMoney = 22.00m,
                     SuggestedRewardPoints = 100,
                     ActualRewardMoney = 20.00m,
                     ActualRewardPoints = 100,
                     StatusId = 4, // Completed
                     CreatedAt = new DateTime(2025, 6, 3),
                     UpdatedAt = new DateTime(2025, 6, 15),
                     AssignedAdminId = 1
                 },
    new Request
    {
        Id = 4,
        UserId = 5,
        LocationId = 4,
        Title = "Forest Trail Maintenance",
        UrgencyLevel = UrgencyLevel.Low,
        WasteTypeId = 7,
        EstimatedAmount = EstimatedAmount.Small,
        SuggestedRewardMoney = 23.00m,
        SuggestedRewardPoints = 100,
        ActualRewardMoney = 20.00m,
        ActualRewardPoints = 100,
        StatusId = 4, // Completed
        CreatedAt = new DateTime(2025, 6, 4),
        UpdatedAt = new DateTime(2025, 6, 20),
        AssignedAdminId = 1
    }
            );

            builder.Entity<Event>().HasData(
                new Event
                {
                    Id = 1,
                    CreatorUserId = 1,
                    LocationId = 1,
                    Title = "Park Cleanup",
                    EventTypeId = 1,
                    EventDate = new DateTime(2025, 7, 1),
                    EventTime = new TimeSpan(9, 0, 0),
                    StatusId = 2,
                    CreatedAt = new DateTime(2025, 6, 10),
                    UpdatedAt = new DateTime(2025, 6, 10),
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
                },

                 new Event
                 {
                     Id = 3,
                     CreatorUserId = 3,     // carol
                     LocationId = 3,
                     Title = "Street Cleanup",
                     EventTypeId = 2,
                     EventDate = new DateTime(2025, 12, 12),
                     EventTime = new TimeSpan(14, 0, 0),
                     StatusId = 1,
                     CreatedAt = new DateTime(2025, 6, 11),
                     UpdatedAt = new DateTime(2025, 6, 11)
                 },

                 new Event
                 {
                     Id = 4,
                     CreatorUserId = 3,     // carol
                     LocationId = 4,
                     Title = "Forest Cleanup",
                     EventTypeId = 2,
                     EventDate = new DateTime(2025, 12, 12),
                     EventTime = new TimeSpan(14, 0, 0),
                     StatusId = 2,
                     CreatedAt = new DateTime(2025, 6, 11),
                     UpdatedAt = new DateTime(2025, 6, 11)
                 }
            );


            builder.Entity<GalleryShowcase>().HasData(
    new GalleryShowcase
    {
        Id = 1,
        RequestId = 1,
        EventId = null,
        LocationId = 1, // Riverbank Park
        CreatedByAdminId = 1, // alice
        BeforeImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/16879a815fc12df11c9f29cb433ef446.jpg",
        AfterImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/16879a815fc12df11c9f29cb433ef446.jpg",
        Title = "Riverbank Park Cleanup Success",
        Description = "Amazing transformation of Riverbank Park after our community cleanup event. Removed over 30 bags of litter and restored the natural beauty.",
        LikesCount = 45,
        DislikesCount = 2,
        IsFeatured = true,
        IsApproved = true,
        IsReported = false,
        ReportCount = 0,
        CreatedAt = new DateTime(2025, 6, 10)
    },
    new GalleryShowcase
    {
        Id = 2,
        RequestId = 2,
        EventId = null,
        LocationId = 2, // City Beach
        CreatedByAdminId = 1, // alice
        BeforeImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg",
        AfterImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Title = "City Beach Plastic Cleanup",
        Description = "Volunteers worked together to clean City Beach, removing large amounts of plastic waste and debris from the coastline.",
        LikesCount = 78,
        DislikesCount = 1,
        IsFeatured = true,
        IsApproved = true,
        IsReported = false,
        ReportCount = 0,
        CreatedAt = new DateTime(2025, 6, 20)
    },
    new GalleryShowcase
    {
        Id = 3,
        RequestId = 3,
        EventId = null,
        LocationId = 3, // Downtown Square
        CreatedByAdminId = 1, // alice
        BeforeImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg",
        AfterImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Title = "Downtown Square Revitalization",
        Description = "Local business district cleanup and beautification project completed by community volunteers in Sarajevo's downtown area.",
        LikesCount = 32,
        DislikesCount = 0,
        IsFeatured = false,
        IsApproved = true,
        IsReported = false,
        ReportCount = 0,
        CreatedAt = new DateTime(2025, 6, 25)
    },
    new GalleryShowcase
    {
        Id = 4,
        RequestId = 4,
        EventId = null,
        LocationId = 4, // Forest Trail
        CreatedByAdminId = 1, // alice
        BeforeImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/istockphoto-1448602820-170667a.jpg",
        AfterImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Title = "Forest Trail Maintenance Project",
        Description = "Hiking trail cleared of fallen branches and litter, new trail markers installed for better navigation.",
        LikesCount = 28,
        DislikesCount = 3,
        IsFeatured = false,
        IsApproved = true,
        IsReported = false,
        ReportCount = 0,
        CreatedAt = new DateTime(2025, 6, 30)
    }
    );

            builder.Entity<GalleryReaction>().HasData(
    // Reactions for Gallery Showcase 1 (Riverbank Park)
    new GalleryReaction { Id = 1, GalleryShowcaseId = 1, UserId = 2, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 11) },
    new GalleryReaction { Id = 2, GalleryShowcaseId = 1, UserId = 3, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 12) },
    new GalleryReaction { Id = 3, GalleryShowcaseId = 1, UserId = 4, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 13) },
    new GalleryReaction { Id = 4, GalleryShowcaseId = 1, UserId = 5, ReactionType = ReactionType.Dislike, CreatedAt = new DateTime(2025, 6, 14) },

    // Reactions for Gallery Showcase 2 (City Beach)
    new GalleryReaction { Id = 5, GalleryShowcaseId = 2, UserId = 1, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 21) },
    new GalleryReaction { Id = 6, GalleryShowcaseId = 2, UserId = 4, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 22) },
    new GalleryReaction { Id = 7, GalleryShowcaseId = 2, UserId = 5, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 23) },
    new GalleryReaction { Id = 8, GalleryShowcaseId = 2, UserId = 6, ReactionType = ReactionType.Dislike, CreatedAt = new DateTime(2025, 6, 24) },

    // Reactions for Gallery Showcase 3 (Downtown Square)
    new GalleryReaction { Id = 9, GalleryShowcaseId = 3, UserId = 2, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 26) },
    new GalleryReaction { Id = 10, GalleryShowcaseId = 3, UserId = 5, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 6, 27) },

    // Reactions for Gallery Showcase 4 (Forest Trail)
    new GalleryReaction { Id = 11, GalleryShowcaseId = 4, UserId = 1, ReactionType = ReactionType.Like, CreatedAt = new DateTime(2025, 7, 1) },
    new GalleryReaction { Id = 12, GalleryShowcaseId = 4, UserId = 3, ReactionType = ReactionType.Dislike, CreatedAt = new DateTime(2025, 7, 2) }
);
            builder.Entity<Photo>().HasData(
    // Photos for Request 1 (Riverbank Park)
    new Photo
    {
        Id = 1,
        RequestId = 1,
        EventId = null,
        UserId = 2, // bob
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Caption = "Initial state of Riverbank Park with scattered litter",
        PhotoType = PhotoType.Before,
        IsPrimary = true,
        UploadedAt = new DateTime(2025, 6, 1),
        OrderIndex = 1
    },
    new Photo
    {
        Id = 2,
        RequestId = 1,
        EventId = null,
        UserId = 2, // bob
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg",
        Caption = "Clean Riverbank Park after community cleanup",
        PhotoType = PhotoType.After,
        IsPrimary = false,
        UploadedAt = new DateTime(2025, 6, 10),
        OrderIndex = 2
    },

    // Photos for Request 2 (City Beach)
    new Photo
    {
        Id = 3,
        RequestId = 2,
        EventId = null,
        UserId = 3, // carol
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Caption = "City Beach covered with plastic waste",
        PhotoType = PhotoType.Before,
        IsPrimary = true,
        UploadedAt = new DateTime(2025, 6, 2),
        OrderIndex = 1
    },
    new Photo
    {
        Id = 4,
        RequestId = 2,
        EventId = null,
        UserId = 3, // carol
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg",
        Caption = "Pristine City Beach after plastic removal",
        PhotoType = PhotoType.After,
        IsPrimary = false,
        UploadedAt = new DateTime(2025, 6, 20),
        OrderIndex = 2
    },

    // Photos for Request 3 (Downtown Square)
    new Photo
    {
        Id = 5,
        RequestId = 3,
        EventId = null,
        UserId = 4, // david
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Caption = "Downtown Square before cleanup",
        PhotoType = PhotoType.Before,
        IsPrimary = true,
        UploadedAt = new DateTime(2025, 6, 3),
        OrderIndex = 1
    },
    new Photo
    {
        Id = 6,
        RequestId = 3,
        EventId = null,
        UserId = 4, // david
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg",
        Caption = "Revitalized Downtown Square",
        PhotoType = PhotoType.After,
        IsPrimary = false,
        UploadedAt = new DateTime(2025, 6, 25),
        OrderIndex = 2
    },

    // Photos for Request 4 (Forest Trail)
    new Photo
    {
        Id = 7,
        RequestId = 4,
        EventId = null,
        UserId = 5, // eve
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Caption = "Forest trail blocked by debris",
        PhotoType = PhotoType.Before,
        IsPrimary = true,
        UploadedAt = new DateTime(2025, 6, 4),
        OrderIndex = 1
    },
    new Photo
    {
        Id = 8,
        RequestId = 4,
        EventId = null,
        UserId = 5, // eve
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/0e474596096b5c9718b87ecb790f4aa4.jpg",
        Caption = "Clear forest trail with new markers",
        PhotoType = PhotoType.After,
        IsPrimary = false,
        UploadedAt = new DateTime(2025, 6, 30),
        OrderIndex = 2
    },
    new Photo
    {
        Id = 9,
        RequestId = 4,
        EventId = null,
        UserId = 6, // frank
        ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
        Caption = "Volunteers installing trail markers",
        PhotoType = PhotoType.Progress,
        IsPrimary = false,
        UploadedAt = new DateTime(2025, 6, 28),
        OrderIndex = 3
    },
     new Photo
     {
         Id = 10,
         RequestId = null,
         EventId = 3,
         UserId = 6, // frank
         ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
         Caption = "Volunteers installing trail markers",
         PhotoType = PhotoType.Progress,
         IsPrimary = false,
         UploadedAt = new DateTime(2025, 6, 28),
         OrderIndex = 3
     },
      new Photo
      {
          Id = 11,
          RequestId = null,
          EventId = 4,
          UserId = 6, // frank
          ImageUrl = "https://ecochallengeblob.blob.core.windows.net/ecochallenge/premium_photo-1690957591806-95a2b81b1075.jpeg",
          Caption = "Volunteers installing trail markers",
          PhotoType = PhotoType.Progress,
          IsPrimary = false,
          UploadedAt = new DateTime(2025, 6, 28),
          OrderIndex = 3
      }

);// 8) EventParticipants
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

            builder.Entity<BalanceSetting>().HasData(
                    new BalanceSetting
                    {
                        Id = 1,
                        WholeBalance = 20000.00m,
                        BalanceLeft = 1800.00m,
                        UpdatedAt = new DateTime(2024, 01, 01),
                        UpdatedByAdminId = null
                    }
                );

            builder.Entity<RequestParticipation>().HasData(
    new RequestParticipation
    {
        Id = 1,
        UserId = 1,
        RequestId = 3,
        Status = ParticipationStatus.Pending,
        AdminNotes = null,
        RewardPoints = 0,
        RewardMoney = 0.00m,
        SubmittedAt = new DateTime(2025, 8, 1, 14, 30, 0, DateTimeKind.Utc),
        ApprovedAt = null
    },
    new RequestParticipation
    {
        Id = 2,
        UserId = 2,
        RequestId = 4,
        Status = ParticipationStatus.Approved,
        AdminNotes = "Good job! Cleaned thoroughly.",
        RewardPoints = 50,
        RewardMoney = 10.00m,
        SubmittedAt = new DateTime(2025, 8, 1, 15, 00, 0, DateTimeKind.Utc),
        ApprovedAt = new DateTime(2025, 8, 2, 10, 00, 0, DateTimeKind.Utc)
    }
);


        }
    }
}
