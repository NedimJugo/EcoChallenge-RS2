using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EcoChallenge.Services.Database.Entities
{
    public class BalanceSetting
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public decimal WholeBalance { get; set; }

        [Required]
        public decimal BalanceLeft { get; set; }

        [Column("updated_at")]
        public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

        [ForeignKey(nameof(UpdatedBy))]
        public int? UpdatedByAdminId { get; set; }
        public virtual User? UpdatedBy { get; set; }
    }

}
