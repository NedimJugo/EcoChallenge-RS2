using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class DonationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? OrganizationId { get; set; }
        public int? StatusId { get; set; }
        public bool? IsAnonymous { get; set; }
        public decimal? MinAmount { get; set; }
        public decimal? MaxAmount { get; set; }
    }
}
