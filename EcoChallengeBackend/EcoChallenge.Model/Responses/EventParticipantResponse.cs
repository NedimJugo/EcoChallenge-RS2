using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class EventParticipantResponse
    {
        public int Id { get; set; }
        public int EventId { get; set; }
        public int UserId { get; set; }
        public DateTime JoinedAt { get; set; }
        public AttendanceStatus Status { get; set; }
        public int PointsEarned { get; set; }
    }
}
