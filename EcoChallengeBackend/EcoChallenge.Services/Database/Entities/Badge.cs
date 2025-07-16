using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class Badge
    {
        [Key]
        public int Id { get; set; }
        [Required, Column("name"), MaxLength(100)]
        public string? Name { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("icon_url"), MaxLength(255)]
        public string? IconUrl { get; set; }
        [Required, ForeignKey(nameof(BadgeType)), Column("badge_type_id")]
        public int BadgeTypeId { get; set; }
        public virtual BadgeType? BadgeType { get; set; }
        [Required, ForeignKey(nameof(CriteriaType)), Column("criteria_type_id")]
        public int CriteriaTypeId { get; set; }
        public virtual CriteriaType? CriteriaType { get; set; }
        [Column("criteria_value")]
        public int CriteriaValue { get; set; }
        [Column("is_active")]
        public bool IsActive { get; set; } = true;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<UserBadge>? UserBadges { get; set; }
        public virtual ICollection<Reward>? Rewards { get; set; }
    }
}
