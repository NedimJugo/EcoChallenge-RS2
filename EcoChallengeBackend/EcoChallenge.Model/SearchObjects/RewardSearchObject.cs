using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class RewardSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? RewardTypeId { get; set; }
        public RewardStatus? Status { get; set; }
        public int? ApprovedByAdminId { get; set; }
        public int? DonationId { get; set; }
        public int? EventId { get; set; }
    }
}
