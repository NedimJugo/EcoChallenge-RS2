using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestRequest
    {
        [Required, MaxLength(200)]
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public int? EstimatedCleanupTime { get; set; }
        public UrgencyLevel UrgencyLevel { get; set; }
        public WasteType WasteType { get; set; }
        public EstimatedAmount EstimatedAmount { get; set; }
        public DateTime? ProposedDate { get; set; }
        public TimeSpan? ProposedTime { get; set; }
        public int LocationId { get; set; }
        public int UserId { get; set; }
    }
}
