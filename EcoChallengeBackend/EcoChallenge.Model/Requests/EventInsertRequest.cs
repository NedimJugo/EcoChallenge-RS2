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
        [Required(ErrorMessage = "Creator User ID is required")]
        public int CreatorUserId { get; set; }

        [Required(ErrorMessage = "Location ID is required")]
        public int LocationId { get; set; }

        [Required(ErrorMessage = "Title is required")]
        [StringLength(200, ErrorMessage = "Title cannot exceed 200 characters")]
        public string Title { get; set; } = string.Empty;

        [StringLength(2000, ErrorMessage = "Description cannot exceed 2000 characters")]
        public string? Description { get; set; }

        [StringLength(255, ErrorMessage = "Image URL cannot exceed 255 characters")]
        [Url(ErrorMessage = "Please provide a valid URL for the image")]
        public string? ImageUrl { get; set; }

        [Required(ErrorMessage = "Event type is required")]
        public EventType EventType { get; set; } = EventType.Cleanup;

        [Range(0, 10000, ErrorMessage = "Max participants must be between 0 and 10000")]
        public int MaxParticipants { get; set; } = 0;

        [Required(ErrorMessage = "Event date is required")]
        [DataType(DataType.Date)]
        public DateTime EventDate { get; set; }

        [Required(ErrorMessage = "Event time is required")]
        [DataType(DataType.Time)]
        public TimeSpan EventTime { get; set; }

        [Range(15, 1440, ErrorMessage = "Duration must be between 15 minutes and 24 hours")]
        public int DurationMinutes { get; set; } = 120;

        public bool EquipmentProvided { get; set; } = false;

        [StringLength(1000, ErrorMessage = "Equipment list cannot exceed 1000 characters")]
        public string? EquipmentList { get; set; }

        [StringLength(500, ErrorMessage = "Meeting point cannot exceed 500 characters")]
        public string? MeetingPoint { get; set; }

        public EventStatus Status { get; set; } = EventStatus.Draft;

        public bool IsPaidRequest { get; set; } = false;

        public int? RelatedRequestId { get; set; }

        public bool AdminApproved { get; set; } = false;
    }
}
