using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database.Entities
{
    public class PasswordReset
    {
        [Key]
        public int Id { get; set; }

        [Required, Column("user_id")]
        public int UserId { get; set; }

        [Required, Column("email"), MaxLength(100)]
        public string Email { get; set; }

        [Required, Column("reset_code"), MaxLength(10)]
        public string ResetCode { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        [Column("expires_at")]
        public DateTime ExpiresAt { get; set; }

        [Column("is_used")]
        public bool IsUsed { get; set; } = false;

        [Column("used_at")]
        public DateTime? UsedAt { get; set; }

        // Navigation
        public virtual User User { get; set; }
    }
}
