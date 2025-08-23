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
        [Required, ForeignKey(nameof(EventType)), Column("event_type_id")]
        public int EventTypeId { get; set; }
        public virtual EventType? EventType { get; set; }
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

        [Required, ForeignKey(nameof(Status)), Column("status_id")]
        public int StatusId { get; set; }
        public virtual EventStatus? Status { get; set; }
        [Column("admin_approved")]
        public bool AdminApproved { get; set; } = false;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<Photo>? Photos { get; set; }
        public virtual ICollection<EventParticipant>? Participants { get; set; }
        public virtual ICollection<GalleryShowcase>? GalleryShowcases { get; set; }
        public virtual ICollection<ActivityHistory>? ActivityLogs { get; set; }
    }
}
