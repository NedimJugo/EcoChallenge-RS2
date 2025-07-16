using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class EventSearchObject : BaseSearchObject
    {
        public string? Text { get; set; }
        public int? Status { get; set; }
        public int? Type { get; set; }
        public int? CreatorUserId { get; set; }
        public int? LocationId { get; set; }
    }
}
