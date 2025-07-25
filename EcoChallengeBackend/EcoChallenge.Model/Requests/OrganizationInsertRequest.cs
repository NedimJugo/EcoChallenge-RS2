using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class OrganizationInsertRequest
    {
        [Required, MaxLength(100)]
        public string? Name { get; set; }

        public string? Description { get; set; }

        [MaxLength(255)]
        public string? Website { get; set; }
        public IFormFile? LogoImage { get; set; } // ✅ Add this

        [MaxLength(100)]
        public string? ContactEmail { get; set; }

        [MaxLength(20)]
        public string? ContactPhone { get; set; }

        [MaxLength(50)]
        public string? Category { get; set; }

        // IsVerified and IsActive usually set by admins or defaults, so optional here or omit
        public bool IsVerified { get; set; } = false;
        public bool IsActive { get; set; } = true;

    }
}