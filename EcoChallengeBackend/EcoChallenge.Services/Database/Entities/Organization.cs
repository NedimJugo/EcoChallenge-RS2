using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace EcoChallenge.Services.Database.Entities
{
    public class Organization
    {
        [Key]
        public int Id { get; set; }
        [Required, Column("name"), MaxLength(100)]
        public string? Name { get; set; }
        [Column("description")]
        public string? Description { get; set; }
        [Column("website"), MaxLength(255)]
        public string? Website { get; set; }
        [Column("logo_url"), MaxLength(255)] 
        public string? LogoUrl { get; set; }

        [Column("contact_email"), MaxLength(100)]
        public string? ContactEmail { get; set; }
        [Column("contact_phone"), MaxLength(20)]
        public string? ContactPhone { get; set; }
        [Column("category"), MaxLength(50)]
        public string? Category { get; set; }
        [Column("is_verified")]
        public bool IsVerified { get; set; } = false;
        [Column("is_active")]
        public bool IsActive { get; set; } = true;
        [Column("created_at")]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        // Navigation properties
        public virtual ICollection<Donation>? Donations { get; set; }
    }
}
