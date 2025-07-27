using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RewardInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        public int? RequestId { get; set; }
        public int? EventId { get; set; }
        public int? DonationId { get; set; }

        [Required]
        public int RewardTypeId { get; set; }

        public int PointsAmount { get; set; }
        public decimal MoneyAmount { get; set; } = 0m;

        [MaxLength(3)]
        public string Currency { get; set; } = "USD";

        public int? BadgeId { get; set; }

        public string? Reason { get; set; }

        [Required]
        public RewardStatus Status { get; set; } = RewardStatus.Pending;

        public int? ApprovedByAdminId { get; set; }

        public DateTime? ApprovedAt { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
