using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class BadgeResponse
    {
        public int Id { get; set; }
        public string? Name { get; set; }
        public string? Description { get; set; }
        public string? IconUrl { get; set; }
        public int BadgeTypeId { get; set; }
        public int CriteriaTypeId { get; set; }
        public int CriteriaValue { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public BadgeTypeResponse? BadgeType { get; set; }
        public CriteriaTypeResponse? CriteriaType { get; set; }
    }
}
