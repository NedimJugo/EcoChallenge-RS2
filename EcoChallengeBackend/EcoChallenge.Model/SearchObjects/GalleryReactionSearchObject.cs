using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class GalleryReactionSearchObject : BaseSearchObject
    {
        public int? UserId { get; set; }
        public int? GalleryShowcaseId { get; set; }
    }

}
