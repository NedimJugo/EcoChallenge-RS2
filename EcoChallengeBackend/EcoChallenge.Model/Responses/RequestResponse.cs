using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class RequestResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public UrgencyLevel UrgencyLevel { get; set; }
        public WasteType WasteType { get; set; }
        public EstimatedAmount EstimatedAmount { get; set; }
        public DateTime? ProposedDate { get; set; }
        public TimeSpan? ProposedTime { get; set; }
        public RequestStatus Status { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
