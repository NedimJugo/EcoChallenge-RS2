using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.AI_Models
{
    public class AggregatedWasteAnalysis
    {
        public Dictionary<string, double> WasteTypePercentages { get; set; } = new();
        public double TotalEstimatedWeight { get; set; }
        public double TotalEstimatedVolume { get; set; }
        public string DominantWasteType { get; set; }
        public string OverallQuantityLevel { get; set; }
        public List<string> ProcessedImageUrls { get; set; } = new();
    }
}
