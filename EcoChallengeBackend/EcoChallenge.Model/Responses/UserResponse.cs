using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class UserResponse
    {
        public int Id { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FirstName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string? ProfileImageUrl { get; set; }
        public string? PhoneNumber { get; set; }
        public DateTime? DateOfBirth { get; set; }
        public string? City { get; set; }
        public string? Country { get; set; }
        public int TotalPoints { get; set; }
        public int TotalCleanups { get; set; }
        public int TotalEventsOrganized { get; set; }
        public int TotalEventsParticipated { get; set; }
        public int UserTypeId { get; set; }
        public bool IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? LastLogin { get; set; }
        public DateTime? DeactivatedAt { get; set; }
        // Collection of roles assigned to the user
        public string? UserTypeName { get; set; } // <- dodano
    }
}
