using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class ChallengeSearchObject
    {
        public string? Code { get; set; }
        public string? CodeGTE { get; set; }
        public string? FTS { get; set; }

    }
}
