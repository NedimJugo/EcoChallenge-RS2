using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class EventParticipantUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        public int? EventId { get; set; }
        public int? UserId { get; set; }
        public AttendanceStatus? Status { get; set; }
        public int? PointsEarned { get; set; }
    }
}
