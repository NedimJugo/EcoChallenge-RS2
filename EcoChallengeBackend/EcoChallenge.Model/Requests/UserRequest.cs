using EcoChallenge.Models.Enums;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class UserRequest
    {
        [Required, MaxLength(50)]
        public string Username { get; set; }

        [Required, MaxLength(100), EmailAddress]
        public string Email { get; set; }

        [Required, MaxLength(255)]
        public string Password { get; set; }  // Plain password or hashed elsewhere

        [Required, MaxLength(50)]
        public string FirstName { get; set; }

        [Required, MaxLength(50)]
        public string LastName { get; set; }

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
        public UserType UserType { get; set; } = UserType.User;

        public bool IsActive { get; set; } = true;
    }
}
