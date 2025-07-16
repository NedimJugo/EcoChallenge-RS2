using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class RequestSearchObject : BaseSearchObject
    {
        public string? Text { get; set; }
        public int? Status { get; set; }
        public int? WasteTypeId { get; set; }
        public UrgencyLevel? UrgencyLevel { get; set; }
        public EstimatedAmount? EstimatedAmount { get; set; }
        public int? LocationId { get; set; }
        public int? UserId { get; set; }
        public int? AssignedAdminId { get; set; }
    }
}
