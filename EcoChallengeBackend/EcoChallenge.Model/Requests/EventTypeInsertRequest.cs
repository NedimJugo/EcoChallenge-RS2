using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class EventTypeInsertRequest
    {
        [Required, MaxLength(100)]
        public string Name { get; set; } = string.Empty;
    }
}
