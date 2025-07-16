using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class EventInsertRequest
    {
        [Required]
        public int CreatorUserId { get; set; }

        [Required]
        public int LocationId { get; set; }

        [Required, MaxLength(200)]
        public string Title { get; set; } = string.Empty;

        public string? Description { get; set; }

        [MaxLength(255)]
        public string? ImageUrl { get; set; }

        [Required]
        public int EventTypeId { get; set; }

        public int MaxParticipants { get; set; } = 0;

        [Required]
        public DateTime EventDate { get; set; }

        [Required]
        public TimeSpan EventTime { get; set; }

        public int DurationMinutes { get; set; } = 120;

        public bool EquipmentProvided { get; set; } = false;

        public string? EquipmentList { get; set; }

        public string? MeetingPoint { get; set; }

        [Required]
        public int StatusId { get; set; }

        public bool IsPaidRequest { get; set; } = false;

        public int? RelatedRequestId { get; set; }

        public bool AdminApproved { get; set; } = false;
    }
}
