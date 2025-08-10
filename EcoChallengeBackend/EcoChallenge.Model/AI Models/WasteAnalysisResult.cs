using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.AI_Models
{
    public class WasteAnalysisResult
    {
        public List<WasteItem> DetectedWaste { get; set; } = new();
        public double TotalConfidenceScore { get; set; }
        public string AnalysisTimestamp { get; set; } = DateTime.UtcNow.ToString();
        public string ImageUrl { get; set; }
    }
}
