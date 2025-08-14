using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class NotificationUpdateRequest
    {
        [Required]
        public int Id { get; set; }

        public NotificationType? NotificationType { get; set; }

        [MaxLength(200)]
        public string? Title { get; set; }

        public string? Message { get; set; }

        public bool? IsRead { get; set; }

        public bool? IsPushed { get; set; }

        public DateTime? ReadAt { get; set; }
    }
}
