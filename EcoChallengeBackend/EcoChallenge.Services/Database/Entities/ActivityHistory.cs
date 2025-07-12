using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Database.Entities
{
    public class ActivityHistory
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")] 
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Required, Column("activity_type")] 
        public ActivityType ActivityType { get; set; }
        [Required, Column("related_entity_type")] 
        public EntityType RelatedEntityType { get; set; }
        [Required, Column("related_entity_id")] 
        public int RelatedEntityId { get; set; }
        [Column("description")] 
        public string? Description { get; set; }
        [Column("points_earned")] 
        public int? PointsEarned { get; set; }
        [Column("money_earned"), Precision(10,2)] 
        public decimal? MoneyEarned { get; set; }
        [Column("created_at")] 
        public DateTime? CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
