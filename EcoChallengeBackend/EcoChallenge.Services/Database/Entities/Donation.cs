using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Database.Entities
{
    public class Donation
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")] 
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [ForeignKey(nameof(Organization)), Column("organization_id")]
        public int OrganizationId { get; set; }
        public virtual Organization? Organization { get; set; }

        [Column("amount"), Precision(10,2)]
        public decimal Amount { get; set; }
        [Column("currency"), MaxLength(3)]
        public string Currency { get; set; } = "USD";
        [Column("payment_method"), MaxLength(50)]
        public string? PaymentMethod { get; set; }
        [Column("payment_reference"), MaxLength(100)]
        public string? PaymentReference { get; set; }
        [Column("donation_message")]
        public string? DonationMessage { get; set; }
        [Column("is_anonymous")]
        public bool IsAnonymous { get; set; } = false;
        [Required, Column("status")]
        public DonationStatus Status { get; set; } = DonationStatus.Pending;
        [Column("points_earned")]
        public int PointsEarned { get; set; }
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("processed_at")]
        public DateTime? ProcessedAt { get; set; }

        // Navigation properties
        public virtual ICollection<Reward>? Rewards { get; set; }
        public virtual ICollection<ActivityHistory>? ActivityLogs { get; set; }
    }
}
