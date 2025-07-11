using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Database.Entities
{
    public class Reward
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")] 
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [ForeignKey(nameof(Request)), Column("request_id")]
        public int? RequestId { get; set; }
        public virtual Request? Request { get; set; }

        [ForeignKey(nameof(Event)), Column("event_id")]
        public int? EventId { get; set; }
        public virtual Event? Event { get; set; }

        [ForeignKey(nameof(Donation)), Column("donation_id")]
        public int? DonationId { get; set; }
        public virtual Donation? Donation { get; set; }

        [Required, Column("reward_type")]
        public RewardType RewardType { get; set; }
        [Column("points_amount")]
        public int PointsAmount { get; set; }
        [Column("money_amount"), Precision(10,2)]
        public decimal MoneyAmount { get; set; }
        [Column("currency"), MaxLength(3)] 
        public string Currency { get; set; } = "USD";

        [ForeignKey(nameof(Badge)), Column("badge_id")] 
        public int? BadgeId { get; set; }
        public virtual Badge? Badge { get; set; }

        [Column("reason")] 
        public string? Reason { get; set; }
        [Required, Column("status")] 
        public RewardStatus Status { get; set; } = RewardStatus.Pending;

        [ForeignKey(nameof(ApprovedBy)), Column("approved_by_admin_id")] 
        public int? ApprovedByAdminId { get; set; }
        public virtual User? ApprovedBy { get; set; }

        [Column("created_at")] 
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("approved_at")] 
        public DateTime? ApprovedAt { get; set; }
        [Column("paid_at")] 
        public DateTime? PaidAt { get; set; }

        // Navigation properties
        public virtual ICollection<ActivityHistory>? ActivityLogs { get; set; }
        public virtual ICollection<Notification>? Notifications { get; set; }
    }
}
