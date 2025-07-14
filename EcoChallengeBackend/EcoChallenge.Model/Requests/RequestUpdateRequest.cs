using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestUpdateRequest
    {

        [MaxLength(200)]
        public string? Title { get; set; }

        public string? Description { get; set; }

        [MaxLength(255)]
        public string? ImageUrl { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Estimated cleanup time must be greater than 0")]
        public int? EstimatedCleanupTime { get; set; }

        public UrgencyLevel? UrgencyLevel { get; set; }

        public WasteType? WasteType { get; set; }

        public EstimatedAmount? EstimatedAmount { get; set; }

        [DataType(DataType.Date)]
        public DateTime? ProposedDate { get; set; }

        [DataType(DataType.Time)]
        public TimeSpan? ProposedTime { get; set; }

        public RequestStatus? Status { get; set; }

        public string? AdminNotes { get; set; }

        public string? RejectionReason { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Suggested reward points must be non-negative")]
        public int? SuggestedRewardPoints { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Suggested reward money must be non-negative")]
        public decimal? SuggestedRewardMoney { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Actual reward points must be non-negative")]
        public int? ActualRewardPoints { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Actual reward money must be non-negative")]
        public decimal? ActualRewardMoney { get; set; }

        public string? AiAnalysisResult { get; set; }

        [MaxLength(255)]
        public string? CompletionImageUrl { get; set; }

        public string? CompletionNotes { get; set; }

        public int? AssignedAdminId { get; set; }

        public DateTime? ApprovedAt { get; set; }

        public DateTime? CompletedAt { get; set; }
    }
}
