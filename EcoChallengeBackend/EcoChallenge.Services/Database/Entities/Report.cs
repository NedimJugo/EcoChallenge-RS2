using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class Report
    {
        [Key] 
        public int Id { get; set; }

        [ForeignKey(nameof(Reporter)), Column("reporter_user_id")]
        public int ReporterUserId { get; set; }
        public virtual User? Reporter { get; set; }

        [Required, Column("reported_entity_type")]
        public TargetEntityType EntityType { get; set; }
        [Required, Column("reported_entity_id")]
        public int EntityId { get; set; }

        [Required, Column("report_reason")]
        public ReportReason Reason { get; set; }
        [Column("report_description")]
        public string? Description { get; set; }
        [Column("status")]
        public ReportStatus Status { get; set; } = ReportStatus.Pending;

        [Column("admin_notes")]
        public string? AdminNotes { get; set; }

        [ForeignKey(nameof(ResolvedBy)), Column("resolved_by_admin_id")]
        public int? ResolvedByAdminId { get; set; }
        public virtual User? ResolvedBy { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("resolved_at")]
        public DateTime? ResolvedAt { get; set; }
    }
}
