using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class EventParticipantSearchObject : BaseSearchObject
    {
        public int? EventId { get; set; }
        public int? UserId { get; set; }
    }
}
