using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.ML
{
    public class WastePricingData
    {
        [LoadColumn(0)]
        public float WasteTypeId { get; set; } // 1=plastic, 2=glass, 3=metal, 4=paper, 5=organic, 6=mixed

        [LoadColumn(1)]
        public float EstimatedWeight { get; set; }

        [LoadColumn(2)]
        public float EstimatedVolume { get; set; }

        [LoadColumn(3)]
        public float UrgencyLevel { get; set; } // 1=low, 2=medium, 3=high

        [LoadColumn(4)]
        public float LocationRisk { get; set; } // 1-5 scale based on location

        [LoadColumn(5)]
        public float SeasonalFactor { get; set; } // 0.8-1.2 based on season

        [LoadColumn(6)]
        public float HistoricalDemand { get; set; } // Average requests in area

        [LoadColumn(7)]
        [ColumnName("Label")]
        public float RewardMoney { get; set; } // Target variable
    }
}
