using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class EventResponse
    {
        public int Id { get; set; }
        public string Title { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? ImageUrl { get; set; }
        public EventType EventType { get; set; }
        public int MaxParticipants { get; set; }
        public int CurrentParticipants { get; set; }
        public DateTime EventDate { get; set; }
        public TimeSpan EventTime { get; set; }
        public int DurationMinutes { get; set; }
        public bool EquipmentProvided { get; set; }
        public string? EquipmentList { get; set; }
        public string? MeetingPoint { get; set; }
        public EventStatus Status { get; set; }
        public bool AdminApproved { get; set; }
        public DateTime CreatedAt { get; set; }
    }
}
