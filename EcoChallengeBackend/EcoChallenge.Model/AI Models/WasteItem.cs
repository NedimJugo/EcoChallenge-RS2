using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.AI_Models
{
    public class WasteItem
    {
        public string WasteType { get; set; } // "plastic", "glass", "metal", "organic", "paper", "mixed"
        public string Quantity { get; set; } // "small", "medium", "large", "very_large"
        public double ConfidenceScore { get; set; }
        public string Description { get; set; }
        public double EstimatedWeight { get; set; } // in kg
        public double EstimatedVolume { get; set; } // in cubic meters
    }
}
