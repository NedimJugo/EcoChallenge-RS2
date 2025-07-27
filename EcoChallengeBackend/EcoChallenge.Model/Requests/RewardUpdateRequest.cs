using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RewardUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        public int? UserId { get; set; }
        public int? RequestId { get; set; }
        public int? EventId { get; set; }
        public int? DonationId { get; set; }
        public int? RewardTypeId { get; set; }
        public int? PointsAmount { get; set; }
        public decimal? MoneyAmount { get; set; }
        [MaxLength(3)]
        public string? Currency { get; set; }
        public int? BadgeId { get; set; }
        public string? Reason { get; set; }
        public RewardStatus? Status { get; set; }
        public int? ApprovedByAdminId { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime? PaidAt { get; set; }
    }
}
