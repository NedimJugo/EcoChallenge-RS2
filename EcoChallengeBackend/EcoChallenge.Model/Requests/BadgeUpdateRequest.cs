using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class BadgeUpdateRequest
    {
        public string? Name { get; set; }
        public string? Description { get; set; }
        public IFormFile? IconUrl { get; set; }
        public int? BadgeTypeId { get; set; }
        public int? CriteriaTypeId { get; set; }
        public int? CriteriaValue { get; set; }
        public bool? IsActive { get; set; }
    }

}
