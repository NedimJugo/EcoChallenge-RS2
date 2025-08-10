using EcoChallenge.Models.AI_Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Interfeces
{
    public interface IAzureVisionService
    {
        Task<WasteAnalysisResult> AnalyzeWasteImageAsync(string imageUrl);
        Task<AggregatedWasteAnalysis> AnalyzeMultipleImagesAsync(List<string> imageUrls);
    }
}
