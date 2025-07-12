using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class RequestSearchObject: BaseSearchObject
    {
        public UrgencyLevel? Urgency { get; set; }
        public RequestStatus? Status { get; set; }
        public int? UserId { get; set; }
        public int? LocationId { get; set; }
        public string? Text { get; set; }
    }
}
