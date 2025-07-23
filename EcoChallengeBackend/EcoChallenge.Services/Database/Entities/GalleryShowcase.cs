using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database.Entities
{
    public class GalleryShowcase
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Request)), Column("request_id")]
        public int? RequestId { get; set; }
        public virtual Request? Request { get; set; }

        [ForeignKey(nameof(Event)), Column("event_id")]
        public int? EventId { get; set; }
        public virtual Event? Event { get; set; }

        [ForeignKey(nameof(Location)), Column("location_id")]
        public int LocationId { get; set; }
        public virtual Location? Location { get; set; }

        [ForeignKey(nameof(CreatedByAdmin)), Column("created_by_admin_id")]
        public int CreatedByAdminId { get; set; }
        public virtual User? CreatedByAdmin { get; set; }

        [Required, Column("before_image_url"), MaxLength(255)]
        public string? BeforeImageUrl { get; set; }

        [Required, Column("after_image_url"), MaxLength(255)]
        public string? AfterImageUrl { get; set; }

        [Column("title"), MaxLength(200)]
        public string? Title { get; set; }

        [Column("description")]
        public string? Description { get; set; }

        [Column("likes_count")]
        public int LikesCount { get; set; } = 0;

        [Column("dislikes_count")]
        public int DislikesCount { get; set; } = 0;

        [Column("is_featured")]
        public bool IsFeatured { get; set; } = false;

        [Column("is_approved")]
        public bool IsApproved { get; set; } = true;

        [Column("is_reported")]
        public bool IsReported { get; set; } = false;

        [Column("report_count")]
        public int ReportCount { get; set; } = 0;

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<GalleryReaction>? Reactions { get; set; }
    }


}
