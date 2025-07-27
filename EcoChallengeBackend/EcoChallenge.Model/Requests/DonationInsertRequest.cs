using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class DonationInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int OrganizationId { get; set; }

        [Required]
        [Range(0.01, double.MaxValue)]
        public decimal Amount { get; set; }

        [MaxLength(3)]
        public string Currency { get; set; } = "BAM";

        [MaxLength(50)]
        public string? PaymentMethod { get; set; }

        [MaxLength(100)]
        public string? PaymentReference { get; set; }

        public string? DonationMessage { get; set; }

        public bool IsAnonymous { get; set; } = false;

        [Required]
        public int StatusId { get; set; }

        public int PointsEarned { get; set; } = 0;
    }
}
