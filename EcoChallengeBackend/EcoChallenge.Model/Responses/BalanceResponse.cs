using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Models.Responses
{
    public class BalanceSettingResponse
    {
        public int Id { get; set; }
        public decimal WholeBalance { get; set; }
        public decimal BalanceLeft { get; set; }
        public DateTime UpdatedAt { get; set; }
        public string? UpdatedByName { get; set; }
    }

}
