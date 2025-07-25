using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class BadgeSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public int? BadgeTypeId { get; set; }
    }

}
