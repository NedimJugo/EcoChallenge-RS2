using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class GalleryShowcaseInsertRequest
    {
        public int? RequestId { get; set; }
        public int? EventId { get; set; }

        [Required]
        public int LocationId { get; set; }

        [Required]
        public int CreatedByAdminId { get; set; }

        [Required]
        public IFormFile BeforeImage { get; set; } = null!;

        [Required]
        public IFormFile AfterImage { get; set; } = null!;

        [MaxLength(200)]
        public string? Title { get; set; }

        public string? Description { get; set; }

        public bool IsFeatured { get; set; } = false;
    }

}
