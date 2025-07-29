using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class GalleryShowcaseResponse
    {
        public int Id { get; set; }
        public int? RequestId { get; set; }
        public int? EventId { get; set; }
        public int LocationId { get; set; }
        public int CreatedByAdminId { get; set; }

        public string BeforeImageUrl { get; set; }
        public string AfterImageUrl { get; set; }

        public string? Title { get; set; }
        public string? Description { get; set; }

        public int LikesCount { get; set; }
        public int DislikesCount { get; set; }

        public bool IsFeatured { get; set; }
        public bool IsApproved { get; set; }
        public bool IsReported { get; set; }
        public int ReportCount { get; set; }

        public DateTime CreatedAt { get; set; }
    }

}
