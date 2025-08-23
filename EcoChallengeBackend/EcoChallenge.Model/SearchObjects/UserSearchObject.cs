using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class UserSearchObject : BaseSearchObject
    {
        public string? Text { get; set; }
        public int? UserTypeId { get; set; }
        public bool? IsActive { get; set; }
        public string? Country { get; set; }
        public string? City { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }
    }
}
