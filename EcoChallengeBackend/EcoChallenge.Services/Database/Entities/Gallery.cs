using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Services.Database.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class Gallery
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

        [ForeignKey(nameof(User)), Column("uploader_user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Required, Column("image_url"), MaxLength(255)]
        public string? ImageUrl { get; set; }
        [Required, Column("image_type")]
        public ImageType ImageType { get; set; }
        [Column("caption")]
        public string? Caption { get; set; }
        [Column("likes_count")]
        public int LikesCount { get; set; }
        [Column("dislikes_count")]
        public int DislikesCount { get; set; }
        [Column("is_featured")]
        public bool IsFeatured { get; set; }
        [Column("is_approved")]
        public bool IsApproved { get; set; } = true;
        [Column("is_reported")]
        public bool IsReported { get; set; }
        [Column("report_count")] 
        public int ReportCount { get; set; }
        [Column("uploaded_at")]
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;
        public ICollection<GalleryReaction>? GalleryReactions { get; set; }
    }
}
