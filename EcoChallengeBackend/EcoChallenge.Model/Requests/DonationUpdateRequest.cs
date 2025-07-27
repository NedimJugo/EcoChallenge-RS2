using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class DonationUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
        [Range(0.01, double.MaxValue)]
        public decimal? Amount { get; set; }
        [MaxLength(3)]
        public string? Currency { get; set; }
        [MaxLength(50)]
        public string? PaymentMethod { get; set; }
        [MaxLength(100)]
        public string? PaymentReference { get; set; }
        public string? DonationMessage { get; set; }
        public bool? IsAnonymous { get; set; }
        public int? StatusId { get; set; }
        public int? PointsEarned { get; set; }
        public DateTime? ProcessedAt { get; set; }
    }
}
