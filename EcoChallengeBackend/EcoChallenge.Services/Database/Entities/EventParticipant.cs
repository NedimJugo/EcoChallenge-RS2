using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class EventParticipant
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(Event)), Column("event_id")]
        public int EventId { get; set; }
        public virtual Event? Event { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Column("joined_at")]
        public DateTime JoinedAt { get; set; } = DateTime.UtcNow;
        [Required, Column("attendance_status")]
        public AttendanceStatus Status { get; set; } = AttendanceStatus.Registered;
        [Column("points_earned")]
        public int PointsEarned { get; set; }
    }
}
