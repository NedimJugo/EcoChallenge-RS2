using EcoChallenge.Models.Enums;
using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestParticipationUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        public ParticipationStatus? Status { get; set; }

        public string? AdminNotes { get; set; }

        public int? RewardPoints { get; set; }

        public decimal? RewardMoney { get; set; }

        public DateTime? ApprovedAt { get; set; }

        public List<IFormFile>? Photos { get; set; }
    }
}
