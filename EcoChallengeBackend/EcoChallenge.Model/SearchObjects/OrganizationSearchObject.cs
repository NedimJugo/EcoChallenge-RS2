using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class OrganizationSearchObject : BaseSearchObject
    {
        public string? Text { get; set; }
        public bool? IsVerified { get; set; }
        public bool? IsActive { get; set; }
        public string? Category { get; set; }
    }
}
