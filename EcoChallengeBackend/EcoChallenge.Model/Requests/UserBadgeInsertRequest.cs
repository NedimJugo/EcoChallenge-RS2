using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class UserBadgeInsertRequest
    {
        public int UserId { get; set; }
        public int BadgeId { get; set; }
        public DateTime? EarnedAt { get; set; }
    }

}
