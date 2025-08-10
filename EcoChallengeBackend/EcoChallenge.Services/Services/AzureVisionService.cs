// Services/Services/AzureVisionService.cs - Updated version
using Azure.AI.Vision.ImageAnalysis;
using Azure;
using EcoChallenge.Models.AI_Models;
using EcoChallenge.Services.Interfeces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace EcoChallenge.Services.Services
{
    public class AzureVisionService : IAzureVisionService
    {
        private readonly ImageAnalysisClient _client;
        private readonly ILogger<AzureVisionService> _logger;

        public AzureVisionService(IConfiguration configuration, ILogger<AzureVisionService> logger)
        {
            var endpoint = configuration["AzureVision:Endpoint"];
            var apiKey = configuration["AzureVision:ApiKey"];
            _client = new ImageAnalysisClient(new Uri(endpoint), new AzureKeyCredential(apiKey));
            _logger = logger;
        }

        public async Task<WasteAnalysisResult> AnalyzeWasteImageAsync(string imageUrl)
        {
            try
            {
                var imageUri = new Uri(imageUrl);

                // Try with Caption first, fallback to Tags and Objects only
                ImageAnalysisResult result = null;

                try
                {
                    // First attempt: Try with Caption
                    result = await _client.AnalyzeAsync(
                        imageUri,
                        VisualFeatures.Caption | VisualFeatures.Objects | VisualFeatures.Tags,
                        new ImageAnalysisOptions { Language = "en" });
                }
                catch (Azure.RequestFailedException ex) when (ex.ErrorCode == "InvalidRequest" && ex.Message.Contains("Caption"))
                {
                    _logger.LogWarning("Caption feature not supported in this region, falling back to Tags and Objects only");

                    // Fallback: Use only Tags and Objects
                    result = await _client.AnalyzeAsync(
                        imageUri,
                        VisualFeatures.Objects | VisualFeatures.Tags,
                        new ImageAnalysisOptions { Language = "en" });
                }
                catch (Azure.RequestFailedException ex) when (ex.ErrorCode == "InvalidRequest")
                {
                    _logger.LogWarning("Objects feature not supported, using Tags only");

                    // Final fallback: Use only Tags
                    result = await _client.AnalyzeAsync(
                        imageUri,
                        VisualFeatures.Tags,
                        new ImageAnalysisOptions { Language = "en" });
                }

                return await ProcessVisionResultForWaste(result, imageUrl);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error analyzing image: {ImageUrl}", imageUrl);

                // Return a fallback analysis result instead of throwing
                return CreateFallbackAnalysis(imageUrl);
            }
        }

        private WasteAnalysisResult CreateFallbackAnalysis(string imageUrl)
        {
            _logger.LogWarning("Creating fallback analysis for image: {ImageUrl}", imageUrl);

            return new WasteAnalysisResult
            {
                ImageUrl = imageUrl,
                TotalConfidenceScore = 0.3, // Low confidence for fallback
                DetectedWaste = new List<WasteItem>
                {
                    new WasteItem
                    {
                        WasteType = "mixed",
                        Quantity = "medium",
                        ConfidenceScore = 0.3,
                        Description = "Fallback analysis - unable to process image with AI",
                        EstimatedWeight = 5.0,
                        EstimatedVolume = 0.1
                    }
                }
            };
        }

        private async Task<WasteAnalysisResult> ProcessVisionResultForWaste(ImageAnalysisResult visionResult, string imageUrl)
        {
            var wasteAnalysis = new WasteAnalysisResult
            {
                ImageUrl = imageUrl
            };

            // Analyze caption and tags for waste indicators
            var caption = visionResult.Caption?.Text?.ToLower() ?? "";
            var tags = visionResult.Tags?.Values?.Select(t => t.Name.ToLower()).ToList() ?? new List<string>();
            var objects = visionResult.Objects?.Values?.SelectMany(o => o.Tags?.Select(tag => tag.Name?.ToLower()) ?? new List<string>()).Where(x => !string.IsNullOrEmpty(x)).ToList() ?? new List<string>();

            // Combine all text for analysis
            var allText = $"{caption} {string.Join(" ", tags)} {string.Join(" ", objects)}";

            _logger.LogInformation("Vision analysis text: {AnalysisText}", allText);

            // Waste type detection logic
            var wasteItems = DetectWasteFromText(allText, visionResult.Caption?.Confidence ?? 0.5);
            wasteAnalysis.DetectedWaste = wasteItems;
            wasteAnalysis.TotalConfidenceScore = wasteItems.Any() ? wasteItems.Average(w => w.ConfidenceScore) : 0;

            return wasteAnalysis;
        }

        private List<WasteItem> DetectWasteFromText(string analysisText, double baseConfidence)
        {
            var wasteItems = new List<WasteItem>();

            // Enhanced waste type keywords
            var wasteKeywords = new Dictionary<string, List<string>>
            {
                ["plastic"] = new() { "plastic", "bottle", "bag", "container", "packaging", "wrapper", "cup", "straw", "polythene", "polymer" },
                ["glass"] = new() { "glass", "bottle", "jar", "broken", "window", "mirror", "crystal" },
                ["metal"] = new() { "metal", "can", "aluminum", "steel", "iron", "wire", "scrap", "tin", "copper" },
                ["paper"] = new() { "paper", "cardboard", "newspaper", "magazine", "box", "document", "tissue" },
                ["organic"] = new() { "food", "organic", "fruit", "vegetable", "leaves", "wood", "branch", "compost", "biodegradable" },
                ["mixed"] = new() { "trash", "garbage", "waste", "litter", "debris", "rubbish", "refuse", "dump" }
            };

            // Enhanced quantity indicators
            var quantityKeywords = new Dictionary<string, List<string>>
            {
                ["small"] = new() { "small", "little", "few", "single", "one", "couple", "tiny", "minimal" },
                ["medium"] = new() { "medium", "some", "several", "moderate", "pile", "bunch", "group" },
                ["large"] = new() { "large", "big", "many", "lots", "pile", "heap", "significant", "substantial" },
                ["very_large"] = new() { "huge", "massive", "enormous", "tons", "overwhelming", "everywhere", "abundant" }
            };

            foreach (var wasteType in wasteKeywords)
            {
                var matchCount = wasteType.Value.Count(keyword => analysisText.Contains(keyword));
                if (matchCount > 0)
                {
                    var confidence = Math.Min(0.95, Math.Max(0.3, baseConfidence + (matchCount * 0.15)));

                    // Determine quantity
                    var quantity = "medium"; // default
                    var maxQuantityMatches = 0;

                    foreach (var quantityType in quantityKeywords)
                    {
                        var quantityMatches = quantityType.Value.Count(keyword => analysisText.Contains(keyword));
                        if (quantityMatches > maxQuantityMatches)
                        {
                            maxQuantityMatches = quantityMatches;
                            quantity = quantityType.Key;
                        }
                    }

                    // Estimate weight and volume based on type and quantity
                    var (weight, volume) = EstimateWeightAndVolume(wasteType.Key, quantity);

                    wasteItems.Add(new WasteItem
                    {
                        WasteType = wasteType.Key,
                        Quantity = quantity,
                        ConfidenceScore = confidence,
                        Description = $"Detected {wasteType.Key} waste with {quantity} quantity (matches: {matchCount})",
                        EstimatedWeight = weight,
                        EstimatedVolume = volume
                    });
                }
            }

            // If no specific waste detected, add generic mixed waste
            if (!wasteItems.Any())
            {
                wasteItems.Add(new WasteItem
                {
                    WasteType = "mixed",
                    Quantity = "medium",
                    ConfidenceScore = Math.Max(0.2, baseConfidence * 0.5),
                    Description = "General waste detected - no specific type identified",
                    EstimatedWeight = 5.0,
                    EstimatedVolume = 0.1
                });
            }

            return wasteItems;
        }

        private (double weight, double volume) EstimateWeightAndVolume(string wasteType, string quantity)
        {
            // Base weights in kg and volumes in cubic meters
            var baseWeights = new Dictionary<string, double>
            {
                ["plastic"] = 2.0,
                ["glass"] = 8.0,
                ["metal"] = 15.0,
                ["paper"] = 1.5,
                ["organic"] = 3.0,
                ["mixed"] = 5.0
            };

            var quantityMultipliers = new Dictionary<string, double>
            {
                ["small"] = 0.3,
                ["medium"] = 1.0,
                ["large"] = 3.0,
                ["very_large"] = 8.0
            };

            var baseWeight = baseWeights.GetValueOrDefault(wasteType, 5.0);
            var multiplier = quantityMultipliers.GetValueOrDefault(quantity, 1.0);

            var weight = baseWeight * multiplier;
            var volume = weight * 0.02; // Rough estimate: 1kg = 0.02 cubic meters

            return (weight, volume);
        }

        public async Task<AggregatedWasteAnalysis> AnalyzeMultipleImagesAsync(List<string> imageUrls)
        {
            var allAnalyses = new List<WasteAnalysisResult>();

            // Analyze each image
            foreach (var imageUrl in imageUrls)
            {
                try
                {
                    var analysis = await AnalyzeWasteImageAsync(imageUrl);
                    allAnalyses.Add(analysis);
                }
                catch (Exception ex)
                {
                    _logger.LogWarning(ex, "Failed to analyze image: {ImageUrl}", imageUrl);
                    // Add fallback analysis for failed images
                    allAnalyses.Add(CreateFallbackAnalysis(imageUrl));
                }
            }

            // Aggregate results
            return AggregateAnalyses(allAnalyses);
        }

        private AggregatedWasteAnalysis AggregateAnalyses(List<WasteAnalysisResult> analyses)
        {
            var aggregated = new AggregatedWasteAnalysis
            {
                ProcessedImageUrls = analyses.Select(a => a.ImageUrl).ToList()
            };

            var allWasteItems = analyses.SelectMany(a => a.DetectedWaste).ToList();

            if (!allWasteItems.Any())
            {
                return aggregated;
            }

            // Calculate waste type percentages
            var wasteTypeGroups = allWasteItems.GroupBy(w => w.WasteType);
            var totalWeight = allWasteItems.Sum(w => w.EstimatedWeight);

            foreach (var group in wasteTypeGroups)
            {
                var typeWeight = group.Sum(w => w.EstimatedWeight);
                var percentage = totalWeight > 0 ? (typeWeight / totalWeight) * 100 : 0;
                aggregated.WasteTypePercentages[group.Key] = percentage;
            }

            // Set totals
            aggregated.TotalEstimatedWeight = totalWeight;
            aggregated.TotalEstimatedVolume = allWasteItems.Sum(w => w.EstimatedVolume);

            // Determine dominant waste type
            aggregated.DominantWasteType = aggregated.WasteTypePercentages
                .OrderByDescending(kvp => kvp.Value)
                .FirstOrDefault().Key ?? "mixed";

            // Determine overall quantity level
            aggregated.OverallQuantityLevel = totalWeight switch
            {
                < 5 => "small",
                < 20 => "medium",
                < 50 => "large",
                _ => "very_large"
            };

            return aggregated;
        }
    }
}