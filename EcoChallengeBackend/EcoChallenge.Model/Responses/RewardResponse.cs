using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class RewardResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int? RequestId { get; set; }
        public int? EventId { get; set; }
        public int? DonationId { get; set; }
        public int RewardTypeId { get; set; }
        public int PointsAmount { get; set; }
        public decimal MoneyAmount { get; set; }
        public string Currency { get; set; } = string.Empty;
        public int? BadgeId { get; set; }
        public string? Reason { get; set; }
        public RewardStatus Status { get; set; }
        public int? ApprovedByAdminId { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime? PaidAt { get; set; }

        // Optionally related user/admin names
        public string? UserName { get; set; }
        public string? ApprovedByAdminName { get; set; }
    }
}
