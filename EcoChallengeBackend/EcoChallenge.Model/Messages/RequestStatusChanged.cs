using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Messages
{
    public class RequestStatusChanged
    {
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

        // Reward information for approved requests
        public int? ActualRewardPoints { get; set; }
        public decimal? ActualRewardMoney { get; set; }
    }
}
