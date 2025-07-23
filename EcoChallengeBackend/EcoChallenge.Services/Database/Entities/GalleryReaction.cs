using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using EcoChallenge.Models.Enums;

namespace EcoChallenge.Services.Database.Entities
{
    public class GalleryReaction
    {
        [Key]
        public int Id { get; set; }

        [ForeignKey(nameof(GalleryShowcase)), Column("gallery_showcase_id")]
        public int GalleryShowcaseId { get; set; }
        public virtual GalleryShowcase? GalleryShowcase { get; set; }

        [ForeignKey(nameof(User)), Column("user_id")]
        public int UserId { get; set; }
        public virtual User? User { get; set; }

        [Required, Column("reaction_type")]
        public ReactionType ReactionType { get; set; }

        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }

}
