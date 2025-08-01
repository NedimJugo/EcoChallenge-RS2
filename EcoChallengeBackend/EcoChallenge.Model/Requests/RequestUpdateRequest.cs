﻿using EcoChallenge.Models.Enums;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestUpdateRequest
    {
        [Required]
        public int Id { get; set; }
        public int? LocationId { get; set; }
        public string? Title { get; set; }
        public string? Description { get; set; }
        public int? EstimatedCleanupTime { get; set; }
        public UrgencyLevel? UrgencyLevel { get; set; }
        public int? WasteTypeId { get; set; }
        public EstimatedAmount? EstimatedAmount { get; set; }
        public DateTime? ProposedDate { get; set; }
        public TimeSpan? ProposedTime { get; set; }
        public int? StatusId { get; set; }
        public string? AdminNotes { get; set; }
        public string? RejectionReason { get; set; }
        public int? SuggestedRewardPoints { get; set; }
        public decimal? SuggestedRewardMoney { get; set; }
        public int? ActualRewardPoints { get; set; }
        public decimal? ActualRewardMoney { get; set; }
        public string? AiAnalysisResult { get; set; }
        public string? CompletionImageUrl { get; set; }
        public string? CompletionNotes { get; set; }
        public int? AssignedAdminId { get; set; }
        public DateTime? ApprovedAt { get; set; }
        public DateTime? CompletedAt { get; set; }
        public List<IFormFile>? Photos { get; set; } // NEW
    }
}
