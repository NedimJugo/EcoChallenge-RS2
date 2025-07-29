using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class GalleryShowcaseSearchObject : BaseSearchObject
    {
        public int? LocationId { get; set; }
        public int? CreatedByAdminId { get; set; }
        public bool? IsApproved { get; set; }
        public bool? IsFeatured { get; set; }
        public string? Title { get; set; }
    }

}
