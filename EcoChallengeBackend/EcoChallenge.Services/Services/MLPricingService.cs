using EcoChallenge.Models.AI_Models;
using EcoChallenge.Models.ML;
using EcoChallenge.Services.Database;
using EcoChallenge.Services.Database.Entities;
using EcoChallenge.Services.Interfeces;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.ML;
using Newtonsoft.Json;
using System;
using Microsoft.AspNetCore.Hosting;

using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Extensions.Hosting;

namespace EcoChallenge.Services.Services
{
    public class MLPricingService : IMLPricingService
    {
        private readonly MLContext _mlContext;
        private readonly EcoChallengeDbContext _context;
        private readonly ILogger<MLPricingService> _logger;
        private readonly string _modelPath;
        private ITransformer? _trainedModel;

        public MLPricingService(EcoChallengeDbContext context, ILogger<MLPricingService> logger, IHostEnvironment env)
        {
            _mlContext = new MLContext(seed: 0);
            _context = context;
            _logger = logger;
            _modelPath = Path.Combine(env.ContentRootPath, "ML", "waste-pricing-model.zip");

            // Try to load existing model
            LoadExistingModel();
        }

        private void LoadExistingModel()
        {
            try
            {
                if (File.Exists(_modelPath))
                {
                    _trainedModel = _mlContext.Model.Load(_modelPath, out var modelInputSchema);
                    _logger.LogInformation("Loaded existing ML model from {ModelPath}", _modelPath);
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "Failed to load existing model");
            }
        }

        public async Task<bool> IsModelTrainedAsync()
        {
            return _trainedModel != null || await GetTrainingDataCountAsync() >= 10;
        }

        private async Task<int> GetTrainingDataCountAsync()
        {
            return await _context.Requests
                .Where(r => !string.IsNullOrEmpty(r.AiAnalysisResult) && r.ActualRewardMoney > 0)
                .CountAsync();
        }

        public async Task TrainModelAsync()
        {
            try
            {
                var trainingData = await PrepareTrainingDataAsync();

                if (trainingData.Count < 10)
                {
                    _logger.LogWarning("Insufficient training data. Need at least 10 records, have {Count}", trainingData.Count);

                    // Use rule-based system until we have enough data
                    return;
                }

                var dataView = _mlContext.Data.LoadFromEnumerable(trainingData);

                // Define the training pipeline
                var pipeline = _mlContext.Transforms.Concatenate("Features",
                        nameof(WastePricingData.WasteTypeId),
                        nameof(WastePricingData.EstimatedWeight),
                        nameof(WastePricingData.EstimatedVolume),
                        nameof(WastePricingData.UrgencyLevel),
                        nameof(WastePricingData.LocationRisk),
                        nameof(WastePricingData.SeasonalFactor),
                        nameof(WastePricingData.HistoricalDemand))
                    .Append(_mlContext.Regression.Trainers.Sdca(labelColumnName: "Label", maximumNumberOfIterations: 100));

                // Train the model
                _trainedModel = pipeline.Fit(dataView);

                // Save the model
                Directory.CreateDirectory(Path.GetDirectoryName(_modelPath)!);
                _mlContext.Model.Save(_trainedModel, dataView.Schema, _modelPath);

                _logger.LogInformation("ML model trained and saved successfully with {Count} records", trainingData.Count);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error training ML model");
                throw;
            }
        }

        private async Task<List<WastePricingData>> PrepareTrainingDataAsync()
        {
            var requests = await _context.Requests
                .Include(r => r.Location)
                .Where(r => !string.IsNullOrEmpty(r.AiAnalysisResult) && r.ActualRewardMoney > 0)
                .ToListAsync();

            var trainingData = new List<WastePricingData>();

            foreach (var request in requests)
            {
                try
                {
                    var aiAnalysis = JsonConvert.DeserializeObject<AggregatedWasteAnalysis>(request.AiAnalysisResult!);
                    if (aiAnalysis == null) continue;

                    var wasteTypeId = GetWasteTypeId(aiAnalysis.DominantWasteType);
                    var locationRisk = CalculateLocationRisk(request.Location);
                    var seasonalFactor = CalculateSeasonalFactor(request.CreatedAt);
                    var historicalDemand = await CalculateHistoricalDemandAsync(request.LocationId);

                    trainingData.Add(new WastePricingData
                    {
                        WasteTypeId = wasteTypeId,
                        EstimatedWeight = (float)aiAnalysis.TotalEstimatedWeight,
                        EstimatedVolume = (float)aiAnalysis.TotalEstimatedVolume,
                        UrgencyLevel = (float)request.UrgencyLevel,
                        LocationRisk = locationRisk,
                        SeasonalFactor = seasonalFactor,
                        HistoricalDemand = historicalDemand,
                        RewardMoney = (float)request.ActualRewardMoney
                    });
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Error processing request {RequestId} for training data", request.Id);
                }
            }

            return trainingData;
        }

        public async Task<PricingRecommendation> PredictPricingAsync(AggregatedWasteAnalysis wasteAnalysis, Request request)
        {
            try
            {
                if (_trainedModel == null)
                {
                    // Use rule-based system if model not available
                    return GenerateRuleBasedPricing(wasteAnalysis, request);
                }

                var inputData = new WastePricingData
                {
                    WasteTypeId = GetWasteTypeId(wasteAnalysis.DominantWasteType),
                    EstimatedWeight = (float)wasteAnalysis.TotalEstimatedWeight,
                    EstimatedVolume = (float)wasteAnalysis.TotalEstimatedVolume,
                    UrgencyLevel = (float)request.UrgencyLevel,
                    LocationRisk = CalculateLocationRisk(request.Location),
                    SeasonalFactor = CalculateSeasonalFactor(DateTime.UtcNow),
                    HistoricalDemand = await CalculateHistoricalDemandAsync(request.LocationId)
                };

                var predictionEngine = _mlContext.Model.CreatePredictionEngine<WastePricingData, WastePricingPrediction>(_trainedModel);
                var prediction = predictionEngine.Predict(inputData);

                var suggestedMoney = Math.Max(1m, Math.Round((decimal)prediction.PredictedRewardMoney, 2));
                var suggestedPoints = (int)(suggestedMoney * 10); // 1 dollar = 10 points

                return new PricingRecommendation
                {
                    SuggestedRewardMoney = suggestedMoney,
                    SuggestedRewardPoints = suggestedPoints,
                    ConfidenceScore = 0.85, // You can implement confidence calculation
                    ReasoningFactors = GenerateReasoningFactors(wasteAnalysis, inputData),
                    FactorWeights = new Dictionary<string, double>
                    {
                        ["WasteType"] = 0.3,
                        ["Weight"] = 0.25,
                        ["Volume"] = 0.15,
                        ["Urgency"] = 0.15,
                        ["Location"] = 0.10,
                        ["Seasonal"] = 0.05
                    }
                };
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error predicting pricing");
                return GenerateRuleBasedPricing(wasteAnalysis, request);
            }
        }

        private PricingRecommendation GenerateRuleBasedPricing(AggregatedWasteAnalysis wasteAnalysis, Request request)
        {
            // Base pricing rules
            var basePrice = wasteAnalysis.DominantWasteType switch
            {
                "metal" => 15m,
                "glass" => 8m,
                "plastic" => 5m,
                "paper" => 3m,
                "organic" => 4m,
                _ => 6m // mixed
            };

            // Weight multiplier
            var weightMultiplier = wasteAnalysis.TotalEstimatedWeight switch
            {
                < 5 => 0.5,
                < 15 => 1.0,
                < 30 => 1.5,
                _ => 2.0
            };

            // Urgency multiplier
            var urgencyMultiplier = request.UrgencyLevel switch
            {
                Models.Enums.UrgencyLevel.Low => 0.8,
                Models.Enums.UrgencyLevel.Medium => 1.0,
                Models.Enums.UrgencyLevel.High => 1.3,
                _ => 1.0
            };

            var finalPrice = Math.Round(basePrice * (decimal)weightMultiplier * (decimal)urgencyMultiplier, 2);
            var points = (int)(finalPrice * 10);

            return new PricingRecommendation
            {
                SuggestedRewardMoney = finalPrice,
                SuggestedRewardPoints = points,
                ConfidenceScore = 0.7,
                ReasoningFactors = $"Rule-based: {wasteAnalysis.DominantWasteType} waste, {wasteAnalysis.TotalEstimatedWeight:F1}kg, {request.UrgencyLevel} urgency",
                FactorWeights = new Dictionary<string, double>
                {
                    ["WasteType"] = 0.4,
                    ["Weight"] = 0.35,
                    ["Urgency"] = 0.25
                }
            };
        }

        // Helper methods
        private float GetWasteTypeId(string wasteType) => wasteType switch
        {
            "plastic" => 1f,
            "glass" => 2f,
            "metal" => 3f,
            "paper" => 4f,
            "organic" => 5f,
            _ => 6f // mixed
        };

        private float CalculateLocationRisk(Location? location)
        {
            // Implement based on your location risk factors
            // For now, return a default value
            return 3f; // Medium risk
        }

        private float CalculateSeasonalFactor(DateTime date)
        {
            var month = date.Month;
            return month switch
            {
                12 or 1 or 2 => 1.2f, // Winter - more waste
                6 or 7 or 8 => 1.1f,   // Summer - more outdoor waste
                _ => 1.0f               // Spring/Fall - normal
            };
        }

        private async Task<float> CalculateHistoricalDemandAsync(int locationId)
        {
            var thirtyDaysAgo = DateTime.UtcNow.AddDays(-30);
            var count = await _context.Requests
                .Where(r => r.LocationId == locationId && r.CreatedAt >= thirtyDaysAgo)
                .CountAsync();

            return count / 30f; // Average requests per day
        }

        private string GenerateReasoningFactors(AggregatedWasteAnalysis wasteAnalysis, WastePricingData inputData)
        {
            return $"Dominant waste: {wasteAnalysis.DominantWasteType}, " +
                   $"Weight: {wasteAnalysis.TotalEstimatedWeight:F1}kg, " +
                   $"Volume: {wasteAnalysis.TotalEstimatedVolume:F2}m³, " +
                   $"Location risk: {inputData.LocationRisk:F1}, " +
                   $"Seasonal factor: {inputData.SeasonalFactor:F2}";
        }
    }
}
