using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Messages
{
    public class ProofStatusChanged
    {
        public int ParticipationId { get; set; }
        public int RequestId { get; set; }
        public int UserId { get; set; }
        public string UserEmail { get; set; } = string.Empty;
        public string UserName { get; set; } = string.Empty;
        public string RequestTitle { get; set; } = string.Empty;
        public string OldStatus { get; set; } = string.Empty;
        public string NewStatus { get; set; } = string.Empty;
        public string? AdminNotes { get; set; }
        public string? RejectionReason { get; set; }
        public DateTime ChangedAt { get; set; }
        public int? AdminId { get; set; }
        public string? AdminName { get; set; }

        // Reward information for approved proofs
        public int? RewardPoints { get; set; }
        public decimal? RewardMoney { get; set; }

        // Payment information
        public string? CardHolderName { get; set; }
        public string? BankName { get; set; }
        public string? TransactionNumber { get; set; }
    }
}
