using Azure.Core;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{

    public class User
    {
        [Key]
        public int Id { get; set; }
        [Required, Column("username"), MaxLength(50)]
        public string? Username { get; set; }
        [Required, Column("email"), MaxLength(100), EmailAddress]
        public string? Email { get; set; }
        [Required, Column("password_hash"), MaxLength(255)]
        public string? PasswordHash { get; set; }
        [Required, Column("first_name"), MaxLength(50)]
        public string? FirstName { get; set; }
        [Required, Column("last_name"), MaxLength(50)]
        public string? LastName { get; set; }
        [Column("profile_image_url"), MaxLength(255)]
        public string? ProfileImageUrl { get; set; }
        [Column("phone_number"), MaxLength(20)]
        public string? PhoneNumber { get; set; }
        [Column("date_of_birth"), DataType(DataType.Date)]
        public DateTime? DateOfBirth { get; set; }
        [Column("city"), MaxLength(100)]
        public string? City { get; set; }
        [Column("country"), MaxLength(100)]
        public string? Country { get; set; }
        [Column("total_points")]
        public int TotalPoints { get; set; } = 0;
        [Column("total_cleanups")]
        public int TotalCleanups { get; set; } = 0;
        [Column("total_events_organized")]
        public int TotalEventsOrganized { get; set; } = 0;
        [Column("total_events_participated")]
        public int TotalEventsParticipated { get; set; } = 0;
        [Required, ForeignKey(nameof(UserType)), Column("user_type_id")]
        public int UserTypeId { get; set; }
        public virtual UserType? UserType { get; set; }
        [Column("is_active")]
        public bool IsActive { get; set; } = true;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        [Column("last_login")]
        public DateTime? LastLogin { get; set; }
        [Column("deactivated_at")]
        public DateTime? DeactivatedAt { get; set; }

        // Navigation
        public ICollection<Request>? Requests { get; set; }
        public ICollection<Request>? AssignedRequests { get; set; }
        public ICollection<Event>? CreatedEvents { get; set; }
        public ICollection<EventParticipant>? EventParticipants { get; set; }
        public ICollection<ChatMessage>? ChatMessages { get; set; }
        public ICollection<Donation>? Donations { get; set; }
        public ICollection<Reward>? Rewards { get; set; }
        public ICollection<UserBadge>? UserBadges { get; set; }
        public ICollection<Gallery>? Galleries { get; set; }
        public ICollection<GalleryReaction>? GalleryReactions { get; set; }
        public ICollection<ActivityHistory>? ActivityHistories { get; set; }
        public ICollection<AdminLog>? AdminLogs { get; set; }
        public ICollection<SystemSetting>? UpdatedSettings { get; set; }
        public ICollection<Report>? Reports { get; set; }
        public ICollection<Report>? ResolvedReports { get; set; }
        public ICollection<Notification>? Notifications { get; set; }
    }

}
