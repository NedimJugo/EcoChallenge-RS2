using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class DonationResponse
    {
        public int Id { get; set; }
        public int UserId { get; set; }
        public int OrganizationId { get; set; }
        public decimal Amount { get; set; }
        public string Currency { get; set; } = string.Empty;
        public string? PaymentMethod { get; set; }
        public string? PaymentReference { get; set; }
        public string? DonationMessage { get; set; }
        public bool IsAnonymous { get; set; }
        public int StatusId { get; set; }
        public int PointsEarned { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? ProcessedAt { get; set; }

        // Optionally you can include related data like user or organization names if you want
        public string? UserName { get; set; }
        public string? OrganizationName { get; set; }
    }
}
