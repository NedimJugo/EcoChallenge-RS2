using Microsoft.AspNetCore.Http;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class RequestParticipationInsertRequest
    {
        [Required]
        public int UserId { get; set; }

        [Required]
        public int RequestId { get; set; }

        public string? AdminNotes { get; set; }

        public List<IFormFile>? Photos { get; set; }
        public string? CardHolderName { get; set; }
        public string? BankName { get; set; }
        public string? TransactionNumber { get; set; }
    }

}
