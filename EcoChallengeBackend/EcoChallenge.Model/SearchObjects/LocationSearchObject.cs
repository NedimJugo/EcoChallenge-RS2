using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class LocationSearchObject : BaseSearchObject
    {
        public string? Name { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public LocationType? LocationType { get; set; }
    }

}
