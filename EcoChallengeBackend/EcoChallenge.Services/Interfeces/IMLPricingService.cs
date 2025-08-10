using EcoChallenge.Models.AI_Models;
using EcoChallenge.Models.ML;
using EcoChallenge.Services.Database.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IMLPricingService
    {
        Task<PricingRecommendation> PredictPricingAsync(AggregatedWasteAnalysis wasteAnalysis, Request request);
        Task TrainModelAsync();
        Task<bool> IsModelTrainedAsync();
    }
}
