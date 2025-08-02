using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class StripePaymentRequest
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

        public string? DonationMessage { get; set; }

        public bool IsAnonymous { get; set; } = false;

        // Return URL for redirect after payment
        public string? ReturnUrl { get; set; }
    }
}
