using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class RequestParticipationSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }

        public int? RequestId { get; set; }

        public ParticipationStatus? Status { get; set; }
    }
}
