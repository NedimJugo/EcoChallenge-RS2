using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EcoChallenge.Services.Database.Entities
{
    public class UserBadge
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")] 
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [ForeignKey(nameof(Badge)), Column("badge_id")]
        public int BadgeId { get; set; }
        public virtual Badge? Badge { get; set; }

        [Column("earned_at")]
        public DateTime EarnedAt { get; set; } = DateTime.UtcNow;
    }
}
