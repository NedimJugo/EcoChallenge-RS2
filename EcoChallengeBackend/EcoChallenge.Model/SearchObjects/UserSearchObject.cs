using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.SearchObjects
{
    public class UserSearchObject: BaseSearchObject
    {
        public string? Text { get; set; }          // matches username, first name, last name, or email
        public bool? IsActive { get; set; }        // filter by active flag
        public string? City { get; set; }          // exact city match
        public string? Country { get; set; }       // exact country match
    }
}
