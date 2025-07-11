using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class SystemSetting
    {
        [Key] 
        public int SettingId { get; set; }
        [Required, Column("setting_key"), MaxLength(100)]
        public string? Key { get; set; }
        [Column("setting_value")]
        public string? Value { get; set; }
        [Required, Column("setting_type")]
        public SettingType Type { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("is_public")]
        public bool IsPublic { get; set; } = false;

        [ForeignKey(nameof(UpdatedBy)), Column("updated_by_admin_id")]
        public int? UpdatedByAdminId { get; set; }
        public virtual User? UpdatedBy { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    }
}
