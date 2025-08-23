using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class GalleryShowcaseUpdateRequest
    {

        public int? RequestId { get; set; }
        public int? EventId { get; set; }
        public int? LocationId { get; set; }
        public int? CreatedByAdminId { get; set; }

        public IFormFile? BeforeImage { get; set; }
        public IFormFile? AfterImage { get; set; }

        [MaxLength(200)]
        public string? Title { get; set; }

        public string? Description { get; set; }

        public bool? IsFeatured { get; set; }
        public bool? IsApproved { get; set; }
        public bool? IsReported { get; set; }
    }

}
