using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class EventParticipantInsertRequest
    {
        [Required]
        public int EventId { get; set; }

        [Required]
        public int UserId { get; set; }

        [Required]
        public AttendanceStatus Status { get; set; } = AttendanceStatus.Registered;

        public int PointsEarned { get; set; } = 0;
    }
}
