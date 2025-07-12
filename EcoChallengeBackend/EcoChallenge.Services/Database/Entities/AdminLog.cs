using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class AdminLog
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(AdminUser)), Column("admin_user_id")] 
        public int AdminUserId { get; set; }
        public virtual User? AdminUser { get; set; }

        [Required, Column("action_type")] 
        public AdminActionType ActionType { get; set; }
        [Required, Column("target_entity_type")] 
        public TargetEntityType TargetEntityType { get; set; }
        [Column("target_entity_id")] 
        public int? TargetEntityId { get; set; }
        [Column("action_description")] 
        public string? ActionDescription { get; set; }
        [Column("old_values", TypeName = "nvarchar(max)")] 
        public string? OldValues { get; set; }
        [Column("new_values", TypeName = "nvarchar(max)")] 
        public string? NewValues { get; set; }
        [Column("ip_address"), MaxLength(45)] 
        public string? IpAddress { get; set; }
        [Column("user_agent")] 
        public string? UserAgent { get; set; }
        [Column("created_at")] 
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}
