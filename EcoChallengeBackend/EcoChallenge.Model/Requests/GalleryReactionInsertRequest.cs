using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class GalleryReactionInsertRequest
    {
        [Required]
        public int GalleryShowcaseId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public ReactionType ReactionType { get; set; }
    }
}
