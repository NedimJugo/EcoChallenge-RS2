using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class Notification
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")] 
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Required, Column("notification_type")]
        public NotificationType NotificationType { get; set; }
        [Required, Column("title"), MaxLength(200)]
        public string? Title { get; set; }
        [Required, Column("message")]
        public string? Message { get; set; }

        [Column("related_entity_type")]
        public EntityType? RelatedEntityType { get; set; }
        [Column("related_entity_id")]
        public int? RelatedEntityId { get; set; }

        [Column("is_read")]
        public bool IsRead { get; set; } = false;
        [Column("is_pushed")]
        public bool IsPushed { get; set; } = false;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("read_at")]
        public DateTime? ReadAt { get; set; }
       
    }
}
