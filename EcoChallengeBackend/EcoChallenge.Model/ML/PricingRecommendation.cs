using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.ML
{
    public class PricingRecommendation
    {
        public decimal SuggestedRewardMoney { get; set; }
        public int SuggestedRewardPoints { get; set; }
        public double ConfidenceScore { get; set; }
        public string ReasoningFactors { get; set; }
        public Dictionary<string, double> FactorWeights { get; set; } = new();
    }
}
