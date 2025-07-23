using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database.Entities
{
    public class Photo
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(Request)), Column("request_id")]
        public int? RequestId { get; set; }
        public virtual Request? Request { get; set; }

        [ForeignKey(nameof(Event)), Column("event_id")]
        public int? EventId { get; set; }
        public virtual Event? Event { get; set; }

        [ForeignKey(nameof(User)), Column("uploader_user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Required, Column("image_url"), MaxLength(255)]
        public string? ImageUrl { get; set; }

        [Column("caption")]
        public string? Caption { get; set; }

        [Required, Column("photo_type")]
        public PhotoType PhotoType { get; set; } // Before, After, Progress, General

        [Column("is_primary")]
        public bool IsPrimary { get; set; } = false; // Main photo for the request/event

        [Column("uploaded_at")]
        public DateTime UploadedAt { get; set; } = DateTime.UtcNow;

        [Column("order_index")]
        public int OrderIndex { get; set; } = 0; // For sorting photos
    }

}
