using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class EventSearchObject: BaseSearchObject
    {
        public EventType? Type { get; set; }
        public EventStatus? Status { get; set; }
        public int? CreatorUserId { get; set; }
        public int? LocationId { get; set; }
        public string? Text { get; set; }
    }
}
