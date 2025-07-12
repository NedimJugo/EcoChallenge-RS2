using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class Event
    {
        [Key] 
        public int Id { get; set; }
        [ForeignKey(nameof(Creator)), Column("creator_user_id")] 
        public int CreatorUserId { get; set; }
        public virtual User? Creator { get; set; }

        [ForeignKey(nameof(Location)), Column("location_id")]
        public int LocationId { get; set; }
        public virtual Location? Location { get; set; }

        [Required, Column("title"), MaxLength(200)]
        public string? Title { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("image_url"), MaxLength(255)]
        public string? ImageUrl { get; set; }
        [Required, Column("event_type")]
        public EventType EventType { get; set; } = EventType.Cleanup;
        [Column("max_participants")]
        public int MaxParticipants { get; set; } = 0;
        [Column("current_participants")]
        public int CurrentParticipants { get; set; } = 0;

        [Required, Column("event_date"), DataType(DataType.Date)]
        public DateTime EventDate { get; set; }
        [Required, Column("event_time"), DataType(DataType.Time)]
        public TimeSpan EventTime { get; set; }
        [Column("duration_minutes")]
        public int DurationMinutes { get; set; } = 120;
        [Column("equipment_provided")]
        public bool EquipmentProvided { get; set; } = false;
        [Column("equipment_list")]
        public string? EquipmentList { get; set; }
        [Column("meeting_point")]
        public string? MeetingPoint { get; set; }

        [Required, Column("status")]
        public EventStatus Status { get; set; } = EventStatus.Draft;
        [Column("is_paid_request")]
        public bool IsPaidRequest { get; set; } = false;

        [ForeignKey(nameof(RelatedRequest)), Column("related_request_id")]
        public int? RelatedRequestId { get; set; }
        public virtual Request? RelatedRequest { get; set; }

        [Column("admin_approved")]
        public bool AdminApproved { get; set; } = false;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<EventParticipant>? Participants { get; set; }
        public virtual ICollection<ChatMessage>? ChatMessages { get; set; }
        public virtual ICollection<Gallery>? Galleries { get; set; }
        public virtual ICollection<Reward>? Rewards { get; set; }
        public virtual ICollection<ActivityHistory>? ActivityLogs { get; set; }
    }
}
