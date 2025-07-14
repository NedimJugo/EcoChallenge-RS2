using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class UserUpdateRequest
    {

        [MaxLength(50)]
        public string? Username { get; set; }

        [MaxLength(100)]
        [EmailAddress]
        public string? Email { get; set; }

        [MaxLength(255)]
        public string? PasswordHash { get; set; }

        [MaxLength(50)]
        public string? FirstName { get; set; }

        [MaxLength(50)]
        public string? LastName { get; set; }

        [MaxLength(255)]
        public string? ProfileImageUrl { get; set; }

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }

        [DataType(DataType.Date)]
        public DateTime? DateOfBirth { get; set; }

        [MaxLength(100)]
        public string? City { get; set; }

        [MaxLength(100)]
        public string? Country { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Total points must be non-negative")]
        public int? TotalPoints { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Total cleanups must be non-negative")]
        public int? TotalCleanups { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Total events organized must be non-negative")]
        public int? TotalEventsOrganized { get; set; }

        [Range(0, int.MaxValue, ErrorMessage = "Total events participated must be non-negative")]
        public int? TotalEventsParticipated { get; set; }

        public UserType? UserType { get; set; }

        public bool? IsActive { get; set; }

        public DateTime? LastLogin { get; set; }

        public DateTime? DeactivatedAt { get; set; }
    }
}
