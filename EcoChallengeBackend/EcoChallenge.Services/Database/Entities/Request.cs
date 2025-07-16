using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;
using Microsoft.EntityFrameworkCore;

namespace EcoChallenge.Services.Database.Entities
{
    public class Request
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [ForeignKey(nameof(Location)), Column("location_id")]
        public int LocationId { get; set; }
        public virtual Location? Location { get; set; }

        [Required, Column("title"), MaxLength(200)]
        public string? Title { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("image_url"), MaxLength(255)]
        public string? ImageUrl { get; set; }

        [Column("estimated_cleanup_time")]
        public int? EstimatedCleanupTime { get; set; }
        [Required, Column("urgency_level")]
        public UrgencyLevel UrgencyLevel { get; set; } = UrgencyLevel.Medium;
        [Required, ForeignKey(nameof(WasteType)), Column("waste_type_id")]
        public int WasteTypeId { get; set; }
        public virtual WasteType? WasteType { get; set; }
        [Required, Column("estimated_amount")]
        public EstimatedAmount EstimatedAmount { get; set; } = EstimatedAmount.Medium;

        [Column("proposed_date"), DataType(DataType.Date)]
        public DateTime? ProposedDate { get; set; }
        [Column("proposed_time"), DataType(DataType.Time)]
        public TimeSpan? ProposedTime { get; set; }

        [Required, ForeignKey(nameof(Status)), Column("status_id")]
        public int StatusId { get; set; }
        public virtual RequestStatus? Status { get; set; }
        [Column("admin_notes")]
        public string? AdminNotes { get; set; }
        [Column("rejection_reason")]
        public string? RejectionReason { get; set; }
        [Column("suggested_reward_points")]
        public int SuggestedRewardPoints { get; set; }
        [Column("suggested_reward_money"), Precision(10, 2)]
        public decimal SuggestedRewardMoney { get; set; }
        [Column("actual_reward_points")]
        public int ActualRewardPoints { get; set; }
        [Column("actual_reward_money"), Precision(10, 2)]
        public decimal ActualRewardMoney { get; set; }
        [Column("ai_analysis_result", TypeName = "nvarchar(max)")]
        public string? AiAnalysisResult { get; set; }
        [Column("completion_image_url"), MaxLength(255)]
        public string? CompletionImageUrl { get; set; }
        [Column("completion_notes")]
        public string? CompletionNotes { get; set; }

        [ForeignKey(nameof(AssignedAdmin)), Column("assigned_admin_id")]
        public int? AssignedAdminId { get; set; }
        public virtual User? AssignedAdmin { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
        [Column("approved_at")]
        public DateTime? ApprovedAt { get; set; }
        [Column("completed_at")]
        public DateTime? CompletedAt { get; set; }

        // Navigation properties
        public virtual ICollection<Reward>? Rewards { get; set; }
        public virtual ICollection<Gallery>? Galleries { get; set; }
        public virtual ICollection<ActivityHistory>? History { get; set; }
        public ICollection<Event>? Events { get; set; }
    }
}
