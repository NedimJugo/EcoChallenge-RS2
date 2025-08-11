using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class RequestParticipationResponse
    {
        public int Id { get; set; }

        public int UserId { get; set; }

        public int RequestId { get; set; }

        public string? AdminNotes { get; set; }

        public ParticipationStatus Status { get; set; }

        public int RewardPoints { get; set; }

        public decimal RewardMoney { get; set; }

        public DateTime SubmittedAt { get; set; }

        public DateTime? ApprovedAt { get; set; }

        public List<string>? PhotoUrls { get; set; }
        public string? CardHolderName { get; set; }
        public string? BankName { get; set; }
        public string? TransactionNumber { get; set; }
        public string? RejectionReason { get; set; }
    }
}
