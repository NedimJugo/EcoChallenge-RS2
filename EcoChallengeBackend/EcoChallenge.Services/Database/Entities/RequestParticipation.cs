using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class RequestParticipation
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [ForeignKey(nameof(Request)), Column("request_id")]
        public int RequestId { get; set; }
        public virtual Request? Request { get; set; }
        public virtual ICollection<Photo>? Photos { get; set; }

        [Required, Column("status")]
        public ParticipationStatus Status { get; set; } = ParticipationStatus.Pending;

        [Column("admin_notes")]
        public string? AdminNotes { get; set; }

        [Column("reward_points")]
        public int RewardPoints { get; set; }

        [Column("reward_money"), Precision(10, 2)]
        public decimal RewardMoney { get; set; }

        [Column("submitted_at")]
        public DateTime SubmittedAt { get; set; } = DateTime.UtcNow;

        [Column("approved_at")]
        public DateTime? ApprovedAt { get; set; }
    }
}
