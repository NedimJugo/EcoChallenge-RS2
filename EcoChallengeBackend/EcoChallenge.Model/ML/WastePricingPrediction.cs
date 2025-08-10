using Microsoft.ML.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.ML
{
    public class WastePricingPrediction
    {
        [ColumnName("Score")]
        public float PredictedRewardMoney { get; set; }
    }
}
