using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Requests
{
    public class BalanceSettingInsertRequest
    {
        public decimal WholeBalance { get; set; }
        public decimal BalanceLeft { get; set; }
        public int? UpdatedByAdminId { get; set; }
    }
}
