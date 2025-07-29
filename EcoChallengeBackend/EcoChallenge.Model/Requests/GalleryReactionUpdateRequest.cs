using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class GalleryReactionUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        [Required]
        public ReactionType ReactionType { get; set; }
    }

}
