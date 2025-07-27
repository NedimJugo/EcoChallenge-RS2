using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class BalanceSettingUpdateRequest
    {
        [Required]
        public int Id { get; set; }
        public decimal WholeBalance { get; set; }
        public decimal BalanceLeft { get; set; }
        public int? UpdatedByAdminId { get; set; }
    }

}
