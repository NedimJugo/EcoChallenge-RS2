using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int LocationId { get; set; }

        [Required]
        [MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        [MaxLength(255)]
        public string? ImageUrl { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Estimated cleanup time must be greater than 0")]
        public int? EstimatedCleanupTime { get; set; }

        [Required]
        public UrgencyLevel UrgencyLevel { get; set; } = UrgencyLevel.Medium;

        [Required]
        public WasteType WasteType { get; set; } = WasteType.Mixed;

        [Required]
        public EstimatedAmount EstimatedAmount { get; set; } = EstimatedAmount.Medium;

        [DataType(DataType.Date)]
        public DateTime? ProposedDate { get; set; }

        [DataType(DataType.Time)]
        public TimeSpan? ProposedTime { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Suggested reward points must be non-negative")]
        public int SuggestedRewardPoints { get; set; }

        [Range(0, double.MaxValue, ErrorMessage = "Suggested reward money must be non-negative")]
        public decimal SuggestedRewardMoney { get; set; }
    }
}
