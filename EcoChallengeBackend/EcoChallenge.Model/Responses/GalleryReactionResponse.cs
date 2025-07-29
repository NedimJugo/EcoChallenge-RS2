using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class GalleryReactionResponse
    {
        public int Id { get; set; }
        public int GalleryShowcaseId { get; set; }
        public int UserId { get; set; }
        public ReactionType ReactionType { get; set; }
        public DateTime CreatedAt { get; set; }
    }

}
